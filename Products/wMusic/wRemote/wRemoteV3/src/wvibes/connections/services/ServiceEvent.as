package wvibes.connections.services
{
	import flash.events.Event;
	
	public class ServiceEvent extends Event
	{
		public static const SPOTIFY_CONNECTED : String = "service_connection_spotify_connected_event";
		public static const DEEZER_CONNECTED : String = "service_connection_deezer_connected_event";
		
		public static const FAILED : String = "service_connection_failed_event";
		
		public function ServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}