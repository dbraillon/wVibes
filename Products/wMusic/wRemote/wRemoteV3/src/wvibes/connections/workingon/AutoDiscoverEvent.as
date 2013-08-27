package wvibes.connections.workingon
{
	import flash.events.Event;
	
	public class AutoDiscoverEvent extends Event
	{
		public function AutoDiscoverEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}