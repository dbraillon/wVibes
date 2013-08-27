package com.dbraillon.pocspotifymobile.connections
{
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
			public static var CONNECTION_ESTABLISHED_EVENT : String = "connection_established_event";
			public static var CONNECTION_ERROR_EVENT : String = "connection_error_event";
			public static var CONNECTION_LOST_EVENT : String = "connection_lost_event";
			
			// evenements de donnees recu
			public static var DATA_RECEIVED_EVENT : String = "response_search_event";
			
			// type de donnees recu
			public static var SEARCH_RESULT_BEGIN_DATA  : String = "<results>";
			public static var SEARCH_RESULT_END_DATA    : String = "</results>";
			public static var PLAYING_RESULT_BEGIN_DATA : String = "<playings>";
			public static var PLAYING_RESULT_END_DATA 	: String = "</playings>";
		
		// --->
		
		private var _isConnected:Boolean;
		private var _address:String = "10.18.18.153";
		private var _port:int = 1338;
		
		private var _parentsEventDispatcher:Array;
		private var _connection:Connection;
		
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
			addEventListener(Connection.CONNECTED_EVENT, onConnectionEstablishedHandler);
			addEventListener(Connection.ERROR_EVENT, onConnectionErrorHandler);
			addEventListener(Connection.CONNECTION_LOST_EVENT, onConnectionLostHandler);
		}
		
		public function addParentDispatcher(parentEventDispatcher:EventDispatcher):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addEventDispatcher(" + parentEventDispatcher.toString() + ")");
			
			// ajout d'un propagateur d'evenement
			
			_parentsEventDispatcher.push(parentEventDispatcher);
		}
		
		public function connect():void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "connect()");
			
			_connection.connect(_address, _port);
		}
		
		
		/*
		 * send commands
		 */
		
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
		
		public function sendLoadMusic(uri:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendLoadMusic");
		}
		
		public function askPlayingMusic():void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendPlayingMusic");
			
			var command:Command = new Command(Command.PLAYER_RECIPIENT, Command.PLAYING_METHOD, new Array());
			_connection.sendCommand(command);
		}
		
		public function sendLoginPassword(login:String, password:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "sendLoginPassword");
			
			var command:Command = new Command(Command.ACCOUNT_RECIPIENT, Command.LOGIN_METHOD, new Array("othane", "TestRaphio"));
			_connection.sendCommand(command);
		}
		
		
		/*
		 * private functions
		 */
		
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
		
		private function isNewPacket(response:String):Boolean
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "isNewPacket(" + response + ")");
			
			if(response.indexOf(SEARCH_RESULT_BEGIN_DATA) >= 0)
			{
				_currentResponseType = SEARCH_RESULT_BEGIN_DATA;
				return true;
			}
			
			if(response.indexOf(PLAYING_RESULT_BEGIN_DATA) >= 0)
			{
				_currentResponseType = PLAYING_RESULT_BEGIN_DATA;
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
			
			if(_currentResponseType == PLAYING_RESULT_BEGIN_DATA)
			{
				if(response.indexOf(PLAYING_RESULT_END_DATA) >= 0)
				{
					return true;
				}
			}
			
			return false;
		}
		
		
		/*
		 * handlers
		 */
		
		// connection handler
		protected function onConnectionEstablishedHandler(event:Event):void
		{
			Log.write(Log.INFO_LEVEL, flash.utils.getQualifiedClassName(this), "onConnectionEstablishedHandler(" + event.toString() + ")");
			
			parentsDispatchEvent(new Event(CONNECTION_ESTABLISHED_EVENT));
		}
		
		protected function onConnectionErrorHandler(event:Event):void
		{
			Log.write(Log.WARNING_LEVEL, flash.utils.getQualifiedClassName(this), "onConnectionErrorHandler(" + event.toString() + ")");
			
			parentsDispatchEvent(new Event(CONNECTION_ERROR_EVENT));
		}
		
		protected function onConnectionLostHandler(event:Event):void
		{
			Log.write(Log.WARNING_LEVEL, flash.utils.getQualifiedClassName(this), "onConnectionLostHandler(" + event.toString() + ")");
			
			parentsDispatchEvent(new Event(CONNECTION_LOST_EVENT));
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
		
		
		/*
		 * getters and setters
		 */
		
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