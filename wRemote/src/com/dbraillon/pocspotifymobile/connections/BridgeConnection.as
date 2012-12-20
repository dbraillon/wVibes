package com.dbraillon.pocspotifymobile.connections
{
	import com.dbraillon.pocspotifymobile.AddressManager;
	import com.dbraillon.pocspotifymobile.Command;
	import com.dbraillon.pocspotifymobile.Log;
	import com.dbraillon.pocspotifymobile.events.DataReceivedEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;

	public class BridgeConnection extends EventDispatcher
	{	
		private static var _instance:BridgeConnection;
		
		public static function getInstance():BridgeConnection
		{
			if(!_instance)
			{
				throw new Error("Use new instead of getInstance for the first use.");
			}
			
			return _instance;
		}
		
		// nom des evenements possibles
		
			// evenements de connexion
			public static var BEGIN_LOCAL_SEARCH_EVENT		: String = "begin_local_search_event";
			public static var NOTFOUND_LOCAL_SEARCH_EVENT	: String = "notfound_local_search_event";
			public static var FOUND_LOCAL_SEARCH_EVENT		: String = "found_local_search_event";
			public static var BEGIN_BASIC_SEARCH_EVENT		: String = "begin_basic_search_event";
			public static var NOTFOUND_BASIC_SEARCH_EVENT	: String = "notfound_basic_search_event";
			public static var FOUND_BASIC_SEARCH_EVENT		: String = "found_basic_search_event";
			public static var BEGIN_CUSTOM_SEARCH_EVENT		: String = "begin_custom_search_event";
			public static var NOTFOUND_CUSTOM_SEARCH_EVENT	: String = "notfound_custom_search_event";
			public static var FOUND_CUSTOM_SEARCH_EVENT		: String = "found_custom_search_event";
			public static var CONNECTION_LOST_EVENT 		: String = "connection_lost_event";
			
			// evenements de donnees recu
			public static var DATA_RECEIVED_EVENT : String = "response_search_event";
			
			// type de donnees recu
			public static var SEARCH_RESULT_BEGIN_DATA : String = "<results>";
			public static var SEARCH_RESULT_END_DATA   : String = "</results>";
		
		// --->
		
		
		private var _isConnected:Boolean;
		private var _address:String = "";
		private var _port:int = 1338;
		
		private var _parentsEventDispatcher:Array;
		private var _connection:Connection;
		private var _addressManager:AddressManager;
		
		private var _isBuildingResponse:Boolean;
		private var _currentResponseType:String;
		private var _responseBuffer:String;
		
		public function BridgeConnection(parentEventDispatcher:EventDispatcher)
		{
			if(_instance)
			{
				Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "Use getInstance instead of new for the further use.");
				throw new Error("Use getInstance instead of new for the further use.");
			}
			
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "BridgeConnection(" + parentEventDispatcher.toString() + ")");
			
			_instance = this;
			
			_isBuildingResponse = false;
			_currentResponseType = "";
			_responseBuffer = "";
			
			_isConnected = false;
			_parentsEventDispatcher = new Array();
			_parentsEventDispatcher.push(parentEventDispatcher);
			_connection = new Connection(this);
			
			// ajout des evenements
			addEventListener(Connection.DATA_RECEIVED_EVENT, onDataReceived);
			addEventListener(Connection.CONNECTION_LOST_EVENT, onConnectionLost);
			addEventListener(Connection.ERROR_EVENT, onConnectionLost);
		}
		
		public function addEventDispatcher(parentEventDispatcher:EventDispatcher):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addEventDispatcher(" + parentEventDispatcher.toString() + ")");
			
			// ajout d'un propagateur d'evenement
			
			_parentsEventDispatcher.push(parentEventDispatcher);
		}
		
		private function parentsDispatchEvent(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "parentsDispatchEvent(" + event.toString() + ")");
			
			// disperse l'evenement à tous les propagateurs
			
			var length:int = _parentsEventDispatcher.length;
			for(var i:int = 0; i < length; i++)
			{
				var eventDispatcher:EventDispatcher = _parentsEventDispatcher[i];
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		protected function onDataReceived(event:DataReceivedEvent):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "onDataReceived(" + event.toString() + ")");
			
			var data:String = event.data;
			
			if(isNewPacket(data))
			{
				_responseBuffer = data;
			}
			else
			{
				_responseBuffer = _responseBuffer.concat(data);
				if(isEndPacket(data))
				{
					var responseEvent:DataReceivedEvent = new DataReceivedEvent(DATA_RECEIVED_EVENT);
					responseEvent.data = _responseBuffer;
					responseEvent.dataType = _currentResponseType;
					
					parentsDispatchEvent(responseEvent);
					
					_responseBuffer = "";
					_currentResponseType = "";
				}
			}
		}
		
		private function isNewPacket(response:String):Boolean
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isNewPacket(" + response + ")");
			
			if(response.indexOf(SEARCH_RESULT_BEGIN_DATA) >= 0)
			{
				_currentResponseType = SEARCH_RESULT_BEGIN_DATA;
				return true;
			}
			
			return false;
		}
		
		private function isEndPacket(response:String):Boolean
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isEndPacket(" + response + ")");
			
			if(_currentResponseType == SEARCH_RESULT_BEGIN_DATA)
			{
				if(response.indexOf(SEARCH_RESULT_END_DATA) >= 0)
				{
					return true;
				}
			}
			
			return false;
		}
		
		protected function onConnectionLost(event:Event):void
		{
			Log.write(Log.WARNING_LEVEL, flash.utils.getQualifiedClassName(this), "onConnectionLost(" + event.toString() + ")");
			
			parentsDispatchEvent(new Event(CONNECTION_LOST_EVENT));
		}
		
		
		
		
		
		
		
		// recherche d'une configuration locale
		public function searchLocalConfiguration():void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "searchLocalConfiguration()");
			
			// on commence la recherche locale
			parentsDispatchEvent(new Event(BEGIN_LOCAL_SEARCH_EVENT));
			
			// récupération du store
			var so:SharedObject = SharedObject.getLocal("bridge_connection");
			
			// récupération de la valeur "connection" de l'objet contenu dans le store
			var tempAddress:String = so.data.connection;
			
			if(tempAddress != null)
			{
				// si il y a bien une address on tente de se connecter dessus
				addEventListener(Connection.CONNECTED_EVENT, localConnectionConnectedHandler);
				addEventListener(Connection.ERROR_EVENT, localConnectionErrorHandler);
				
				_connection.connect(tempAddress, _port);
			}
			else
			{
				// sinon la recherche a échoué
				parentsDispatchEvent(new Event(NOTFOUND_LOCAL_SEARCH_EVENT));
			}
		}
		
		protected function localConnectionErrorHandler(event:Event):void
		{
			Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "localConnectionErrorHandler(" + event.toString() + ")");
			
			// une erreur est survenu, la recherche locale a échoué
			
			removeEventListener(Connection.CONNECTED_EVENT, localConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, localConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(NOTFOUND_LOCAL_SEARCH_EVENT));
		}
		
		protected function localConnectionConnectedHandler(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "localConnectionConnectedHandler(" + event.toString() + ")");
			
			// la connexion est établie
			_isConnected = true;
			
			removeEventListener(Connection.CONNECTED_EVENT, localConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, localConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(FOUND_LOCAL_SEARCH_EVENT));
		}
		// fin de la recherche de configuration locale
		
		
		// recherche d'une configuration basique
		public function launchSearchBasicConfiguration():void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "launchSearchBasicConfiguration()");
			
			_addressManager = new AddressManager("192.168", 0, 0, 1, 5);
			searchBasicConfiguration(_addressManager.nextAddress());
		}
		
		public function searchBasicConfiguration(address:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "searchBasicConfiguration(" + address + ")");
			
			_address = address;
			
			parentsDispatchEvent(new Event(BEGIN_BASIC_SEARCH_EVENT));
			
			
			addEventListener(Connection.CONNECTED_EVENT, basicConnectionConnectedHandler);
			addEventListener(Connection.ERROR_EVENT, basicConnectionErrorHandler);
			
			_connection.connect(_address, _port);
		}
		
		protected function basicConnectionErrorHandler(event:Event):void
		{
			Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "basicConnectionErrorHandler(" + event.toString() + ")");
			
			// une erreur est survenu, la recherche basic a échoué
			
			removeEventListener(Connection.CONNECTED_EVENT, basicConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, basicConnectionErrorHandler);
			
			var address:String = _addressManager.nextAddress();
			if(address == null)
			{
				parentsDispatchEvent(new Event(NOTFOUND_BASIC_SEARCH_EVENT));
			}
			else
			{
				searchBasicConfiguration(address);	
			}
		}
		
		protected function basicConnectionConnectedHandler(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "basicConnectionConnectedHandler(" + event.toString() + ")");
			
			// la connexion est établie
			_isConnected = true;
			
			removeEventListener(Connection.CONNECTED_EVENT, basicConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, basicConnectionErrorHandler);
			
			addLocalConnection();
			
			parentsDispatchEvent(new Event(FOUND_BASIC_SEARCH_EVENT));
		}
		// fin de la recherche de configuration basique
		
		
		public function searchCustomConfiguration(address:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "searchCustomConfiguration(" + address + ")");
			
			_address = address;
			
			addEventListener(Connection.CONNECTED_EVENT, customConnectionConnectedHandler);
			addEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(BridgeConnection.BEGIN_CUSTOM_SEARCH_EVENT));
			
			_connection.connect(_address, _port);
		}
		
		protected function customConnectionErrorHandler(event:Event):void
		{
			Log.write(Log.ERROR_LEVEL, flash.utils.getQualifiedClassName(this), "customConnectionErrorHandler(" + event.toString() + ")");
			
			removeEventListener(Connection.CONNECTED_EVENT, customConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(BridgeConnection.NOTFOUND_CUSTOM_SEARCH_EVENT));
		}
		
		protected function customConnectionConnectedHandler(event:Event):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "customConnectionConnectedHandler(" + event.toString() + ")");
			
			_isConnected = true;
			
			removeEventListener(Connection.CONNECTED_EVENT, customConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			addLocalConnection();
			
			parentsDispatchEvent(new Event(BridgeConnection.FOUND_CUSTOM_SEARCH_EVENT));
		}
		
		private function addLocalConnection():void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addLocalConnection()");
			
			var so:SharedObject = SharedObject.getLocal("bridge_connection");
			so.data.connection = _address;
			so.flush();
		}
		
		public function sendSearchRequest(searchContent:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendSearchRequest(" + searchContent + ")");
			
			var array:Array = new Array();
			array.push(searchContent);
			
			var command:Command = new Command(Command.SEARCH_RECIPIENT, Command.BASIC_METHOD, array);
			_connection.sendCommand(command);
		}
		
		public function sendStartMusic(uri:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendStartMusic(" + uri + ")");
			
			var command:Command = new Command(Command.PLAYER_RECIPIENT, Command.LOAD_METHOD, new Array(uri));
			_connection.sendCommand(command);
			
			for(var i:int = 0; i<100; i++){}
			
			command = new Command(Command.PLAYER_RECIPIENT, Command.PLAY_METHOD, new Array());
			_connection.sendCommand(command);
		}
		
		public function get isConnected():Boolean
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isConnected()");
			
			return _isConnected;
		}
		
		public function set isConnected(value:Boolean):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isConnected(" + value.toString() + ")");
			
			_isConnected = value;
		}
	}
}