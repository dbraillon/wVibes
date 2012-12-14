package com.dbraillon.pocspotifymobile.connections
{
	import com.dbraillon.pocspotifymobile.AddressManager;
	import com.dbraillon.pocspotifymobile.Command;
	import com.dbraillon.pocspotifymobile.Connection;
	import com.dbraillon.pocspotifymobile.events.ResponseEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

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
		
		
		public static var BEGIN_LOCAL_SEARCH_EVENT : String = "begin_local_search_event";
		public static var NOTFOUND_LOCAL_SEARCH_EVENT : String = "notfound_local_search_event";
		public static var FOUND_LOCAL_SEARCH_EVENT : String = "found_local_search_event";
		
		public static var BEGIN_BASIC_SEARCH_EVENT : String = "begin_basic_search_event";
		public static var NOTFOUND_BASIC_SEARCH_EVENT : String = "notfound_basic_search_event";
		public static var FOUND_BASIC_SEARCH_EVENT : String = "found_basic_search_event";
		
		public static var BEGIN_CUSTOM_SEARCH_EVENT : String = "begin_custom_search_event";
		public static var NOTFOUND_CUSTOM_SEARCH_EVENT : String = "notfound_custom_search_event";
		public static var FOUND_CUSTOM_SEARCH_EVENT : String = "found_custom_search_event";
		
		public static var RESPONSE_SEARCH_EVENT : String = "response_search_event";

		public static var SEARCH_RESULT_BEGIN_RESPONSE : String = "<results>";
		public static var SEARCH_RESULT_END_RESPONSE : String = "</results>";
		
		public static var CONNECTION_LOST : String = "connection_lost";
		
		
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
				throw new Error("Use getInstance instead of new for the further use.");
			}
			
			_instance = this;
			
			_isBuildingResponse = false;
			_currentResponseType = "";
			_responseBuffer = "";
			
			_isConnected = false;
			_parentsEventDispatcher = new Array();
			_parentsEventDispatcher.push(parentEventDispatcher);
			_connection = new Connection(this);
			
			addEventListener(Connection.RESPONSE_EVENT, onResponse);
			addEventListener(Connection.CONNECTION_LOST, onConnectionLost);
			addEventListener(Connection.ERROR_EVENT, onConnectionLost);
		}
		
		protected function onConnectionLost(event:Event):void
		{
			parentsDispatchEvent(new Event(CONNECTION_LOST));
		}
		
		public function addEventDispatcher(parentEventDispatcher:EventDispatcher):void
		{
			_parentsEventDispatcher.push(parentEventDispatcher);
		}
		
		public function parentsDispatchEvent(event:Event):void
		{
			var length:int = _parentsEventDispatcher.length;
			for(var i:int = 0; i < length; i++)
			{
				var eventDispatcher:EventDispatcher = _parentsEventDispatcher[i];
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		protected function onResponse(event:ResponseEvent):void
		{
			var response:String = event.response;
			
			if(isNewPacket(response))
			{
				_responseBuffer = response;
			}
			else
			{
				_responseBuffer = _responseBuffer.concat(response);
				if(isEndPacket(response))
				{
					var responseEvent:ResponseEvent = new ResponseEvent(RESPONSE_SEARCH_EVENT);
					responseEvent.response = _responseBuffer;
					responseEvent.responseType = _currentResponseType;
					
					parentsDispatchEvent(responseEvent);
					
					_responseBuffer = "";
					_currentResponseType = "";
				}
			}
		}
		
		private function isNewPacket(response:String):Boolean
		{
			if(response.indexOf(SEARCH_RESULT_BEGIN_RESPONSE) >= 0)
			{
				_currentResponseType = SEARCH_RESULT_BEGIN_RESPONSE;
				return true;
			}
			
			return false;
		}
		
		private function isEndPacket(response:String):Boolean
		{
			if(_currentResponseType == SEARCH_RESULT_BEGIN_RESPONSE)
			{
				if(response.indexOf(SEARCH_RESULT_END_RESPONSE) >= 0)
				{
					return true;
				}
			}
			
			return false;
		}
		
		// recherche d'une configuration locale
		public function searchLocalConfiguration():void
		{
			// on commence la recherche locale
			parentsDispatchEvent(new Event(BEGIN_LOCAL_SEARCH_EVENT));
			
			// récupération du store
			var so:SharedObject = SharedObject.getLocal("bridge_connection");
			
			// récupération de la valeur "connection" de l'objet contenu dans le store
			var tempAddress:String = so.data.connection;
			
			if(tempAddress != null)
			{
				// si il y a bien une address on tente de se connecter dessus
				addEventListener(Connection.CONNECT_EVENT, localConnectionConnectedHandler);
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
			// une erreur est survenu, la recherche locale a échoué
			
			removeEventListener(Connection.CONNECT_EVENT, localConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, localConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(NOTFOUND_LOCAL_SEARCH_EVENT));
		}
		
		protected function localConnectionConnectedHandler(event:Event):void
		{
			// la connexion est établie
			_isConnected = true;
			
			removeEventListener(Connection.CONNECT_EVENT, localConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, localConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(FOUND_LOCAL_SEARCH_EVENT));
		}
		// fin de la recherche de configuration locale
		
		
		// recherche d'une configuration basique
		public function launchSearchBasicConfiguration():void
		{
			_addressManager = new AddressManager("192.168", 0, 0, 1, 5);
			searchBasicConfiguration(_addressManager.nextAddress());
		}
		
		public function searchBasicConfiguration(address:String):void
		{
			_address = address;
			
			parentsDispatchEvent(new Event(BEGIN_BASIC_SEARCH_EVENT));
			
			
			addEventListener(Connection.CONNECT_EVENT, basicConnectionConnectedHandler);
			addEventListener(Connection.ERROR_EVENT, basicConnectionErrorHandler);
			
			_connection.connect(_address, _port);
		}
		
		protected function basicConnectionErrorHandler(event:Event):void
		{
			// une erreur est survenu, la recherche basic a échoué
			trace("Bridge error");
			
			removeEventListener(Connection.CONNECT_EVENT, basicConnectionConnectedHandler);
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
			// la connexion est établie
			_isConnected = true;
			
			removeEventListener(Connection.CONNECT_EVENT, basicConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, basicConnectionErrorHandler);
			
			addLocalConnection();
			
			parentsDispatchEvent(new Event(FOUND_BASIC_SEARCH_EVENT));
		}
		// fin de la recherche de configuration basique
		
		
		public function searchCustomConfiguration(address:String):void
		{
			_address = address;
			
			addEventListener(Connection.CONNECT_EVENT, customConnectionConnectedHandler);
			addEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(BridgeConnection.BEGIN_CUSTOM_SEARCH_EVENT));
			
			_connection.connect(_address, _port);
		}
		
		protected function customConnectionErrorHandler(event:Event):void
		{
			removeEventListener(Connection.CONNECT_EVENT, customConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			parentsDispatchEvent(new Event(BridgeConnection.NOTFOUND_CUSTOM_SEARCH_EVENT));
		}
		
		protected function customConnectionConnectedHandler(event:Event):void
		{
			_isConnected = true;
			
			removeEventListener(Connection.CONNECT_EVENT, customConnectionConnectedHandler);
			removeEventListener(Connection.ERROR_EVENT, customConnectionErrorHandler);
			
			addLocalConnection();
			
			parentsDispatchEvent(new Event(BridgeConnection.FOUND_CUSTOM_SEARCH_EVENT));
		}
		
		private function addLocalConnection():void
		{
			trace("Address found : " + _address);
			
			var so:SharedObject = SharedObject.getLocal("bridge_connection");
			so.data.connection = _address;
			so.flush();
		}
		
		public function sendSearchRequest(searchContent:String):void
		{
			var array:Array = new Array();
			array.push(searchContent);
			
			var command:Command = new Command(Command.SEARCH_RECIPIENT, Command.BASIC_METHOD, array);
			_connection.sendCommand(command);
		}
		
		public function sendStartMusic(uri:String):void
		{
			var command:Command = new Command(Command.PLAYER_RECIPIENT, Command.LOAD_METHOD, new Array(uri));
			_connection.sendCommand(command);
			
			for(var i:int = 0; i<100; i++)
			{
				trace("wait...");
			}
			
			command = new Command(Command.PLAYER_RECIPIENT, Command.PLAY_METHOD, new Array());
			_connection.sendCommand(command);
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function set isConnected(value:Boolean):void
		{
			_isConnected = value;
		}
	}
}