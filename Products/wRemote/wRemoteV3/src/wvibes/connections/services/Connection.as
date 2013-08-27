package wvibes.connections.services
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import wvibes.connections.Address;
	import wvibes.connections.workingon.Command;

	public class Connection extends EventDispatcher
	{
		public static const COMMAND_RESULT : String = "connection_command_result_event";
		public static const COMMAND_FAILED : String = "connection_command_failed_event";
		
		
		// private
		private var _address:Address;
		
		private var socket:Socket;
		private var timer:Timer;
		
		private var _service:Service;
		
		public function Connection() 
		{
			service = new Service(this);
		}

		public function get service():Service
		{
			return _service;
		}

		public function set service(value:Service):void
		{
			_service = value;
		}

		public function discover(address:Address):void
		{
			if(!address || !address.url || !address.port)
			{
				dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCOVER_FAILED));
				return;
			}
			
			trace("+ BridgeConnection.as : discover(" + address.toString() + ")");
			
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, socket_connectedHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_progressHandler);
			socket.addEventListener(Event.CLOSE, socket_closedHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socket_errorHandler);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_errorHandler);
			
			socket.connect(address.url, address.port);
		}
		
		protected function socket_closedHandler(event:Event):void
		{
			trace("- BridgeConnection.as : socket_closedHandler()");
			
			dispatchEvent(new ConnectionEvent(ConnectionEvent.LOST));
		}
		
		protected function socket_connectedHandler(event:Event):void
		{
			trace("+ BridgeConnection.as : socket_connectedHandler()");
			
			timer = new Timer(2000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_completeHandler);
			timer.start();
		}
		
		protected function timer_completeHandler(event:TimerEvent):void
		{
			socket.close();
			dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCOVER_FAILED));
		}
		
		protected function socket_progressHandler(event:ProgressEvent):void
		{
			if(timer.running)
			{
				timer.stop();
			}
			
			var response:int = socket.readInt();
			trace("+ BridgeConnection.as : socket_progressHandler(" + response + ")");
			
			switch(response)
			{
				case ConnectionResponse.HELLO:
					
					address = new Address(socket.remoteAddress, socket.remotePort);
					dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCOVER_SUCCED));
					break;
				
				default:
					break;
			}
		}
		
		protected function socket_errorHandler(event:ErrorEvent):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCOVER_FAILED));
		}
		
		public function sendCommand(command:Command):void
		{
			if(socket.connected)
			{
				trace("+ BridgeConnection : sendCommand(" + command.toString() + ")");
				
				var httpService:HTTPService = new HTTPService();
				httpService.resultFormat = "text";
				httpService.method = "GET";
				httpService.showBusyCursor = true;
				httpService.requestTimeout = 20;
				
				httpService.url = "http://" + address.url + ":3000/";
				httpService.url += command.toString();
				
				httpService.addEventListener(ResultEvent.RESULT, httpRequest_resultHandler);
				httpService.addEventListener(FaultEvent.FAULT, httpRequest_faultHandler);
				httpService.send();
			}
		}
		
		protected function httpRequest_resultHandler(event:ResultEvent):void
		{
			dispatchEvent(event);
		}
		
		protected function httpRequest_faultHandler(event:FaultEvent):void
		{
			dispatchEvent(event);
		}

		
		public function get address():Address
		{
			if(!_address)
			{
				_address = new Address(SharedObject.getLocal("bridge_connection").data.url, 
									   SharedObject.getLocal("bridge_connection").data.port);
			}
			
			return _address;
		}
		
		public function set address(value:Address):void
		{
			SharedObject.getLocal("bridge_connection").data.url = value.url;
			SharedObject.getLocal("bridge_connection").data.port = value.port;
		}
	}
}