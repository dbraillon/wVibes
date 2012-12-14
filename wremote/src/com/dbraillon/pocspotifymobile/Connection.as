package com.dbraillon.pocspotifymobile
{
	import com.dbraillon.pocspotifymobile.events.ResponseEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;

	public class Connection
	{
		// nom des évenements possibles
		public static var CONNECT_EVENT  : String = "connect_event";
		public static var ERROR_EVENT    : String = "error_event";
		public static var RESPONSE_EVENT : String = "response_event";
		public static var CONNECTION_LOST : String = "connection_lost";
		
		private var _connectionSocket:Socket;
		private var _parentEventDispatcher:EventDispatcher;
		
		
		public function Connection(parentEventDispatcher:EventDispatcher)
		{
			_parentEventDispatcher = parentEventDispatcher;
		}
		
		
		public function connect(address:String, port:int):void
		{
			trace("Connecting to : " + address + ":" + port + "...");
			
			// avant un essai de connexion, on tente de fermer une possible précédente connexion
			closeSocket();
			
			
			// construction de la nouvelle connexion
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
			// une erreur de sécurité est survenu, la connexion se ferme et on envoie un evenement
			
			trace("Connection failed : Security error");
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			// une erreur IO est survenu, la connexion se ferme et on envoie un evenement
			
			trace("Connection failed : IO error");
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onConnect(event:Event):void
		{
			// la connexion a réussi, on envoie un evenement
			
			trace("Connected to " + _connectionSocket.remoteAddress);
			_parentEventDispatcher.dispatchEvent(new Event(Connection.CONNECT_EVENT));
			
		}
		
		protected function onResponse(event:ProgressEvent):void
		{
			trace("Getting a response from " + _connectionSocket.remoteAddress + "...");
			
			// construction de la réponse
			var response:String = "";
			while(_connectionSocket.bytesAvailable) {
			
				response = response.concat(_connectionSocket.readUTFBytes(_connectionSocket.bytesAvailable));
			}
			
			var responseEvent:ResponseEvent = new ResponseEvent(RESPONSE_EVENT);
			responseEvent.response = response;
			
			_parentEventDispatcher.dispatchEvent(responseEvent);
			
		}
		
		protected function onClose(event:Event):void
		{
			trace("Connection closed");
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(CONNECTION_LOST));
		}
		
		
		
		public function sendCommand(command:Command):void
		{
			var commandString:String = command.toString();
			
			trace("Send command : " + commandString);
			
			_connectionSocket.writeMultiByte(commandString, "iso-8859-1");
			_connectionSocket.flush();
		}
		
		private function closeSocket():void 
		{
			trace("Close socket");
			
			if(_connectionSocket != null) 
			{
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
}