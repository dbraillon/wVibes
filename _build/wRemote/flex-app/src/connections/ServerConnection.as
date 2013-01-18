package connections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class ServerConnection extends EventDispatcher
	{
		public static var SIGNIN_SUCCED:String = "server_connection_signin_succed";
		public static var SIGNIN_FAILED:String = "server_connection_signin_failed";
		
		private static var _instance:ServerConnection;
		
		private var _eventDispatcher:EventDispatcher;
		
		public function ServerConnection()
		{
			if(_instance)
			{
				throw new Error("Use getInstance() instead of new");
			}
		}
		
		public static function getInstance():ServerConnection
		{
			if(!_instance)
			{
				_instance = new ServerConnection();
			}
			
			return _instance;
		}
		
		public function addEventDispatcher(eventDispatcher:EventDispatcher):void
		{
			_eventDispatcher = eventDispatcher;
		}
		
		public function signinRequest(login:String, password:String):void
		{
			if(_eventDispatcher)
			{
				_eventDispatcher.dispatchEvent(new Event(SIGNIN_SUCCED));
			}
		}
	}
}