package com.wvibes.wremote.connections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	// https://gist.github.com/raphui/d054b6474d05112c287c
	
	
	public class ServerConnection extends EventDispatcher
	{
		public static var REQUEST_SUCCED:String = "server_connection_request_succed";
		public static var REQUEST_FAILED:String = "server_connection_request_failed";
		
		private static var _instance:ServerConnection;
		
		private var _socket:Socket;
		private var _address:String;
		private var _data:Object;
		
		public function ServerConnection()
		{
			_data = new Object();
			_socket = new Socket();
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketRequest_ReceiveHandler);
			_socket.addEventListener(Event.CLOSE, socketRequest_ErrorHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, socketRequest_ErrorHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketRequest_ErrorHandler);
			
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
		
		
		public function changeAddress(address:String):void
		{
			trace("-serverConnection : CHANGE ADDRESS TO " + address);
			
			_address = address;
		}
		
		private function socketRequest_ReceiveHandler(event:ProgressEvent):void
		{
			_data.response = _socket.readUTFBytes(_socket.bytesAvailable);
			
			trace("-serverConnection : RESPONSE " + _data.response);
			
			dispatchEvent(new Event(REQUEST_SUCCED));
		}
		
		private function socketRequest_ErrorHandler(event:Event):void
		{
			if(event is SecurityErrorEvent) 
			{
				var se:SecurityErrorEvent = event as SecurityErrorEvent;
				_data.error = se.text;
			}
			else if(event is IOErrorEvent)
			{
				var ioe:IOErrorEvent = event as IOErrorEvent;
				_data.error = ioe.text;
			}
			else
			{
				_data.error = "Unknown error";
			}
			
			trace("-serverConnection : ERROR " + _data.error);
			
			dispatchEvent(new Event(REQUEST_FAILED));
		}
		
		public function signinRequest(login:String, password:String):void
		{
			trace("-serverConnection : SIGNIN REQUEST LOGIN " + login + " PASSWORD " + password);
			
			_socket.connect(_address, 1338);
			_socket.writeUTFBytes("ACCOUNT#LOGIN#" + login + "%" + password);
		}
		
		public function loadTrackOnStreamRequest(uri:String, stream:String):void
		{
			trace("-serverConnection : LOAD TRACK URI " + uri + " STREAM " + stream);
			
			_socket.connect(_address, 1338);
			_socket.writeUTFBytes("STREAMER#LOAD#" + uri + "%" + stream);
		}
		
		public function playStreamRequest(stream:String):void
		{
			trace("-serverConnection : PLAY STREAM " + stream);
			
			_socket.connect(_address, 1338);
			_socket.writeUTFBytes("STREAMER#PLAY#" + stream);
		}
		
		public function pauseStreamRequest(stream:String):void
		{
			trace("-serverConnection : PAUSE STREAM " + stream);
			
			_socket.connect(_address, 1338);
			_socket.writeUTFBytes("STREAMER#PAUSE#" + stream);
		}
		
		
		/*
		public function signinRequest(login:String, password:String):void
		{
			trace("-signinRequest : LOGIN " + login + " PASSWORD " + password);
			
			
			var httpService:HTTPService = new HTTPService();
			httpService.resultFormat = "text";
			httpService.method = "POST";
			httpService.showBusyCursor = true;
			httpService.requestTimeout = 5;
			
			httpService.url = _address + "login?";
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
			
			//dispatchEvent(new Event(SIGNIN_FAILED));
			dispatchEvent(new Event(SIGNIN_SUCCED));
		}
		
		protected function httpRequest_resultHandler(event:ResultEvent):void
		{
			trace("-signinRequest : SUCCED");
			
			var result:Object = JSON.parse(event.result.toString());
			
			dispatchEvent(new Event(SIGNIN_SUCCED));
		}*/
		
		public function playingMusicRequest():void
		{
			data.source = "http://cdn-images.deezer.com/images/cover/44df4f6fb2534768f4924365c103d0f7/315x315-000000-80-0-0.jpg";
			data.title = "Don't Stay";
			data.artist = "Linkin Park";
			data.current = 26;
			data.end = 185;
			data.isPlaying = true;
			
			//dispatchEvent(new Event(PLAYING_MUSIC_REQUEST_SUCCED));
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