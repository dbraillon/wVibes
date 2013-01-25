package connections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class ServerConnection extends EventDispatcher
	{
		public static var SIGNIN_SUCCED:String = "server_connection_signin_succed";
		public static var SIGNIN_FAILED:String = "server_connection_signin_failed";
		public static var PLAYING_MUSIC_REQUEST_SUCCED:String = "server_connection_playing_music_request_succed";
		public static var PLAYING_MUSIC_REQUEST_FAILED:String = "server_connection_playing_music_request_failed";
		
		private static var _instance:ServerConnection;
		
		
		private var _data:Object;
		
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
		
		
		public function signinRequest(login:String, password:String):void
		{
			trace("-signinRequest : LOGIN " + login + " PASSWORD " + password);
			
			var httpService:HTTPService = new HTTPService();
			httpService.resultFormat = "text";
			httpService.method = "POST";
			httpService.showBusyCursor = true;
			httpService.requestTimeout = 5;
			
			httpService.url = "http://10.18.17.1:9000/login?";
			httpService.url += "username=" + login;
			httpService.url += "&password=" + password;
			httpService.url += "&serviceName=" + "wvibes";
			
			trace("-signinRequest : URL REQUEST " + httpService.url);
			
			httpService.addEventListener(ResultEvent.RESULT, httpRequest_resultHandler);
			httpService.addEventListener(FaultEvent.FAULT, httpRequest_faultHandler);
			httpService.send();
		}
		
		protected function httpRequest_faultHandler(event:FaultEvent):void
		{
			trace("-signinRequest : FAILED");
			
			dispatchEvent(new Event(SIGNIN_FAILED));
		}
		
		protected function httpRequest_resultHandler(event:ResultEvent):void
		{
			trace("-signinRequest : SUCCED");
			
			var result:Object = JSON.parse(event.result.toString());
			
			dispatchEvent(new Event(SIGNIN_SUCCED));
		}
		
		
		public function playingMusicRequest():void
		{
			data.source = "http://cdn-images.deezer.com/images/cover/44df4f6fb2534768f4924365c103d0f7/315x315-000000-80-0-0.jpg";
			data.title = "Don't Stay";
			data.artist = "Linkin Park";
			data.current = 26;
			data.end = 185;
			data.isPlaying = true;
			
			dispatchEvent(new Event(PLAYING_MUSIC_REQUEST_SUCCED));
		}

		public function get data():Object
		{
			if(!_data)
			{
				_data = new Object();
			}
			
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}