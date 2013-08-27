package wvibes.events
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		public static const RETURN_CLICKED : String = "return_clicked";
		public static const SEARCH_CLICKED : String = "search_clicked";
		public static const PLAYLISTS_CLICKED : String = "playlists_clicked";
		public static const PARAMETERS_CLICKED : String = "parameters_clicked";
		
		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}