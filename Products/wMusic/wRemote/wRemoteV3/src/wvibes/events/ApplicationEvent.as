package wvibes.events
{
	import flash.events.Event;
	
	public class ApplicationEvent extends Event
	{
		public static const SEARCH_RESULT : String = "search_result";
		
		private var _data : Array;
		
		public function ApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data = new Array();
		}

		public function get data():Array
		{
			return _data;
		}

		public function set data(value:Array):void
		{
			_data = value;
		}

	}
}