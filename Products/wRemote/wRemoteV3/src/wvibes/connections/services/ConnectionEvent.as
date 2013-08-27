package wvibes.connections.services
{
	import flash.events.Event;
	
	public class ConnectionEvent extends Event
	{
		public static const DISCOVER_SUCCED : String = "discover_succed";
		public static const DISCOVER_FAILED : String = "discover_failed";
		
		public static const REQUEST_SUCCED : String = "request_succed";
		public static const REQUEST_FAILED : String = "request_failed";
		
		public static const LOST	: String = "bridge_connection_lost_event";
		
		// use to notify wRemote.mxml, something change
		public static const PLAY_CHANGED_EVENT    : String = "bg_play_changed_event";
		public static const PLAYING_CHANGED_EVENT : String = "bg_playing_changed_event";
		public static const VOLUME_CHANGED_EVENT  : String = "bg_volume_changed_event";
		
		public static const PLAYING_REQUEST	: String = "bridge_connection_playing_request";
		
		
		public static const VOLUME_REQUEST	: String = "bridge_connection_volume_request";
		
		
		private var _data : Object;
		
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}