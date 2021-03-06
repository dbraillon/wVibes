package com.dbraillon.pocspotifymobile
{
	public class Log
	{
		public static var ERROR_LEVEL	: String = "ERROR";
		public static var WARNING_LEVEL	: String = "WARNING";
		public static var INFO_LEVEL	: String = "INFO";
		public static var LEVEL_1		: String = "LEVEL 1";
		public static var LEVEL_2		: String = "LEVEL 2";
		public static var LEVEL_3		: String = "LEVEL 3";
		
		private static var CURRENT_LEVEL : String;
		
		public static function write(level:String, context:String, message:String):void
		{
			var localDate:Date = new Date();
			
			trace("- " + localDate.time + " [" + level + "](" + context + "): " + message);
		}
	}
}