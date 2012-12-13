package com.dbraillon.pocspotifymobile
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;

	public class Connection
	{
		public static var CONNECT_EVENT  : String = "connect_event";
		public static var ERROR_EVENT    : String = "error_event";
		public static var RESPONSE_EVENT : String = "response_event";
		
		private var _connectionSocket:Socket;
		private var _datagramSocket:DatagramSocket;
		private var _parentEventDispatcher:EventDispatcher;
		
		public function Connection(parentEventDispatcher:EventDispatcher)
		{
			_parentEventDispatcher = parentEventDispatcher;
		}
		
		public function connect(address:String, port:int):void
		{
			trace("Connect to : " + address + ":" + port);
			
			_connectionSocket = new Socket();
			
			_connectionSocket.addEventListener(Event.CONNECT, onConnect);
			_connectionSocket.addEventListener(Event.CLOSE, onClose);
			_connectionSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_connectionSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponse);
			_connectionSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
		
			_connectionSocket.connect(address, port);
		}
		
		protected function onSecError(event:SecurityErrorEvent):void
		{
			trace("Connection failed : Security");
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onResponse(event:ProgressEvent):void
		{
			trace("Response");
			
			var response:String = "";
			while(_connectionSocket.bytesAvailable) {
			
				response = response.concat(_connectionSocket.readUTFBytes(_connectionSocket.bytesAvailable));
			}
			
			
			if(response.indexOf("<results>") >= 0)
			{
				_s = "";
				_b = true;
			}
			
			if(_b)
			{
				startBuffer(response);
			}
			
			if(response.indexOf("</results>") >= 0)
			{
				_b = false;
				trace(_s);
				
				_parentEventDispatcher.dispatchEvent(new Event(Connection.RESPONSE_EVENT));
			}
		}
		public var _s:String = "";
		private var _b:Boolean = false;
		private function startBuffer(s:String)
		{
			_s = _s.concat(s);
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			trace("Connection failed : IO");
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onClose(event:Event):void
		{
			trace("Connection closed");
			closeSocket();
		}
		
		protected function onConnect(event:Event):void
		{
			_parentEventDispatcher.dispatchEvent(new Event(Connection.CONNECT_EVENT));
			trace("Connected");
		}
		
		public function sendCommand(command:Command):void
		{
			_connectionSocket.writeMultiByte(command.toString(), "iso-8859-1");
			_connectionSocket.flush();
		}
		
		public function receiveCommand():void
		{
			
		}
		
		private function closeSocket():void 
		{
			trace("Close socket");
			
			_connectionSocket.removeEventListener(Event.CLOSE, onClose);
			_connectionSocket.removeEventListener(Event.CONNECT, onConnect);
			_connectionSocket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_connectionSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onResponse);
			_connectionSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			
			if(_connectionSocket.connected)
			{
				_connectionSocket.close();	
			}
			
			_connectionSocket = null;
		}
	}
}