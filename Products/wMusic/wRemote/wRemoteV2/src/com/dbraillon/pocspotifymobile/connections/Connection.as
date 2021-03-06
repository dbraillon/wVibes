package com.dbraillon.pocspotifymobile.connections
{
	import com.dbraillon.pocspotifymobile.Command;
	import com.dbraillon.pocspotifymobile.Log;
	import com.dbraillon.pocspotifymobile.events.DataReceivedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;
	import flash.utils.getQualifiedClassName;

	public class Connection
	{
		// nom des evenements possibles
		public static var CONNECTED_EVENT		: String = "connected_event";
		public static var ERROR_EVENT			: String = "error_event";
		public static var DATA_RECEIVED_EVENT	: String = "data_received_event";
		public static var CONNECTION_LOST_EVENT : String = "connection_lost_event";
		
		// socket de connection
		private var _connectionSocket:Socket;
		
		// propagateur d'evenement
		private var _parentEventDispatcher:EventDispatcher;
		
		
		public function Connection(parentEventDispatcher:EventDispatcher)
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "Connection(" + parentEventDispatcher.toString() + ")");
			
			_parentEventDispatcher = parentEventDispatcher;
		}
		
		
		public function connect(address:String, port:int):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "connect(" + address +", " + port + ")");
			
			// avant un essai de connexion, on tente de fermer une possible précédente connexion
			closeSocket();
			
			
			// construction de la nouvelle connexion
			_connectionSocket = new Socket();

			_connectionSocket.addEventListener(Event.CONNECT, onConnected);
			_connectionSocket.addEventListener(ProgressEvent.SOCKET_DATA, onDataReceived);
			_connectionSocket.addEventListener(Event.CLOSE, onClosed);
			_connectionSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_connectionSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);

			_connectionSocket.connect(address, port);
		}
		
		protected function onSecError(event:SecurityErrorEvent):void
		{
			Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "onSecError(" + event.toString() + ")");
			
			// une erreur de sécurité est survenu, la connexion se ferme et on envoie un evenement
			closeSocket();

			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "onError(" + event.toString() + ")");
			
			// une erreur IO est survenu, la connexion se ferme et on envoie un evenement
			closeSocket();

			_parentEventDispatcher.dispatchEvent(new Event(Connection.ERROR_EVENT));
		}
		
		protected function onConnected(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "onConnected(" + event.toString() + ")");
			
			// la connexion a réussi, on envoie un evenement
			_parentEventDispatcher.dispatchEvent(new Event(Connection.CONNECTED_EVENT));
		}
		
		protected function onDataReceived(event:ProgressEvent):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "onDataReceived(" + event.toString() + ")");
			
			// le client distant envoie des donnees construction de la réponse
			var data:String = "";
			while(_connectionSocket.bytesAvailable) {
			
				
				data = data.concat(_connectionSocket.readUTFBytes(_connectionSocket.bytesAvailable));
			}
			
			// envoi d'un evenement au propagateur d'evenement contenant les données reçu
			var dataReceivedEvent:DataReceivedEvent = new DataReceivedEvent(DATA_RECEIVED_EVENT);
			dataReceivedEvent.data = data;
			
			_parentEventDispatcher.dispatchEvent(dataReceivedEvent);
			
		}
		
		protected function onClosed(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "onClosed(" + event.toString() + ")");
			
			// le client distant a fermé la connexion
			closeSocket();
			
			_parentEventDispatcher.dispatchEvent(new Event(CONNECTION_LOST_EVENT));
		}
		
		
		public function sendCommand(command:Command):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isConnected ? " + _connectionSocket.connected);
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendCommand(" + command.toString() + ")");
			
			// envoi une commande au client distant
			
			var commandString:String = command.toString();
			
			_connectionSocket.writeMultiByte(commandString, "iso-8859-1");
			_connectionSocket.flush();
		}
		
		private function closeSocket():void 
		{
			if(_connectionSocket != null) 
			{
				Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "closeSocket()");
				
				_connectionSocket.removeEventListener(Event.CLOSE, onClosed);
				_connectionSocket.removeEventListener(Event.CONNECT, onConnected);
				_connectionSocket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_connectionSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onDataReceived);
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