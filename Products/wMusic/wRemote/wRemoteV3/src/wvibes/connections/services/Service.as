package wvibes.connections.services
{
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import wvibes.connections.workingon.Command;

	public class Service extends EventDispatcher
	{
		private const SPOTIFY : int = 1;
		
		private var _spotifyCredential:Object;
		private var _requestedCredential:Object;
		
		private var connection:Connection;
		
		public function Service(connection:Connection)
		{
			this.connection = connection;
		}
		
		public function registerSpotify(login:String = null, password:String = null):void
		{
			_requestedCredential = new Object();
			_requestedCredential.login = login;
			_requestedCredential.password = password;
			
			var command:Command = new Command();
			command.spotifyCommand(login, password);
			
			connection.addEventListener(ResultEvent.RESULT, request_resultHandler);
			connection.addEventListener(FaultEvent.FAULT, request_failedHandler);
			connection.sendCommand(command);
		}
		
		protected function request_resultHandler(event:ResultEvent):void
		{
			connection.removeEventListener(ResultEvent.RESULT, request_resultHandler);
			connection.removeEventListener(FaultEvent.FAULT, request_failedHandler);
			
			trace("+ ServiceConnection.as : request_resultHandler()");
			
			if(event.result)
			{
				var json:String = event.result as String;
				var result:Object = JSON.parse(json);
				
				if(result.action == "login" && result.status == "OK")
				{
					spotifyCredential = _requestedCredential;
					dispatchEvent(new ServiceEvent(ServiceEvent.SPOTIFY_CONNECTED));
				}
				else
				{
					request_failedHandler(null);
				}
			}
			else
			{
				request_failedHandler(null);
			}
		}
		
		protected function request_failedHandler(event:FaultEvent):void
		{
			connection.removeEventListener(ResultEvent.RESULT, request_resultHandler);
			connection.removeEventListener(FaultEvent.FAULT, request_failedHandler);
			
			trace("- ServiceConnection.as : request_faultHandler()");
			
			dispatchEvent(new ServiceEvent(ServiceEvent.FAILED));
		}

		public function get spotifyCredential():Object
		{
			if(!_spotifyCredential)
			{
				_spotifyCredential = SharedObject.getLocal("spotify_service").data; 
			}
			
			return _spotifyCredential;
		}

		public function set spotifyCredential(value:Object):void
		{
			SharedObject.getLocal("spotify_service").data.login = value.login;
			SharedObject.getLocal("spotify_service").data.password = value.password;
		}
	}
}