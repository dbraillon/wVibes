package com.dbraillon.pocspotifymobile
{
	import flash.utils.getQualifiedClassName;
	
	public class Command
	{
		public static var PLAYER_RECIPIENT : String = "PLAYER";
		public static var SEARCH_RECIPIENT : String = "SEARCH";
		public static var ACCOUNT_RECIPIENT : String = "ACCOUNT";
		
		public static var LOAD_METHOD 	  : String = "LOAD";
		public static var PLAY_METHOD 	  : String = "PLAY";
		public static var PAUSE_METHOD 	  : String = "PAUSE";
		public static var PREVIOUS_METHOD : String = "PREVIOUS";
		public static var NEXT_METHOD 	  : String = "NEXT";
		
		public static var BASIC_METHOD    : String = "BASIC";
		public static var ARTIST_METHOD   : String = "ARTIST";
		public static var ALBUM_METHOD    : String = "ALBUM";
		public static var TRACK_METHOD    : String = "TRACK";
		public static var WHATSNEW_METHOD : String = "WHATSNEW";
		
		public static var PLAYING_METHOD  : String = "PLAYING";
		
		public static var LOGIN_METHOD : String = "LOGIN";
		
		
		private var _recipient:String;
		private var _method:String;
		private var _arguments:Array;
		
		public function Command(recipient:String, method:String, arguments:Array)
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "Command(" + recipient + ", " + method + ", " + arguments.toString() + ")");
			
			_recipient = recipient;
			_method = method;
			_arguments = arguments;
		}
		
		public function toString():String
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "toString()");
			
			var s:String = "";
			
			if(_arguments.length == 0)
			{
				s = _recipient + "#" + _method;
			}
			else
			{
				s = _recipient + "#" + _method + "#";	
			}
			
			for(var i:int = 0; i < _arguments.length; i++)
			{
				if(i + 1 >= _arguments.length)
				{
					s = s.concat(_arguments[i]);
				}
				else
				{
					s = s.concat(_arguments[i] + "%");
				}
			}
			
			return s;
		}
	}
}