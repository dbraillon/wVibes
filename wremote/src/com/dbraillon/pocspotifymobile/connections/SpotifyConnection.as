package com.dbraillon.pocspotifymobile.connections
{
	public class SpotifyConnection
	{
		// singleton
		private static var instance:SpotifyConnection;
		
		// constructor
		public function SpotifyConnection()
		{
			if (instance)
			{
				throw new Error("Please call Connection.getInstance() instead of new.");
			}
		}
		
		// singleton getter
		public static function getInstance():SpotifyConnection
		{
			if (!instance)
			{
				instance = new SpotifyConnection();
			}
			return instance;
		}

		private var _username:String;
		private var _password:String;
		private var _connected:Boolean;
		
		public function get username():String
		{
			return _username;
		}
		
		public function set username(value:String):void
		{
			_username = value;
		}

		public function get password():String
		{
			return _password;
		}

		public function set password(value:String):void
		{
			_password = value;
		}

		public function get connected():Boolean
		{
			return _connected;
		}

		public function set connected(value:Boolean):void
		{
			_connected = value;
		}
	}
}