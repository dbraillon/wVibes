package com.dbraillon.pocspotifymobile
{
	public class Command
	{
		public static var PLAYER_RECIPIENT : String = "PLAYER";
		public static var SEARCH_RECIPIENT : String = "SEARCH";
		
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
		
		
		private var _recipient:String;
		private var _method:String;
		private var _arguments:Array;
		
		public function Command(recipient:String, method:String, arguments:Array)
		{
			_recipient = recipient;
			_method = method;
			_arguments = arguments;
		}
		
		public function toString():String
		{
			var s:String = _recipient + "#" + _method + "#";
			
			for(var i:int = 0; i < _arguments.length; i++)
			{
				if(i + 1 >= _arguments.length)
				{
					s = s.concat(_arguments[i]);
				}
				else
				{
					s = s.concat(_arguments[i] + ",");
				}
			}
			
			trace("Command : " + s);
			return s;
		}
	}
}