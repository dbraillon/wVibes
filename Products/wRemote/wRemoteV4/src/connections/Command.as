package connections
{
	public class Command
	{
		public static const PLAY_COMMAND : String = "play_command";
		public static const STOP_COMMAND : String = "play_command";
		
		private var command:String;
		
		public function addressCommand():void
		{
			command = "bridge/address/";
		}
		
		public function spotifyCommand(login:String, password:String):void
		{
			command = "login/" + login + "/" + password + "/";
		}
		
		public function streamListCommand():void
		{
			command = "stream/list";
		}
		
		public function loadCommand(uri:String, stream:String):void
		{
			command = "load/" + uri + "/" + stream;
		}
		
		public function playCommand(stream:String):void
		{
			command = "play/" + stream;
		}
		
		public function searchCommand(search:String):void
		{
			command = "search/track/" + search;
		}
		
		public function stopCommand(stream:String):void
		{
			command = "pause/" + stream;
		}
		
		public function playingCommand(stream:String):void
		{
			command = "infos/" + stream;
		}
		
		public function volumeCommand(stream:String):void
		{
			command = "volume/" + stream;
		}
		
		public function toString():String
		{
			return command;
		}
	}
}