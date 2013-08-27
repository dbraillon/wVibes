package com.dbraillon.pocspotifymobile.events
{
	import flash.events.Event;

	public class DataReceivedEvent extends Event
	{
		private var _data:String;
		private var _dataType:String;
		
		public function DataReceivedEvent(_type:String, _bubbles:Boolean = true, _cancelable:Boolean = true)
		{
			super(_type, _bubbles, _cancelable);
		}

		override public function clone():Event
		{
			var event:DataReceivedEvent = new DataReceivedEvent(type, bubbles, cancelable);
			event.data = data;
			event.dataType = dataType;
			
			return event as Event;
		}

		public function get data():String
		{
			return _data;
		}

		public function set data(value:String):void
		{
			_data = value;
		}

		public function get dataType():String
		{
			return _dataType;
		}

		public function set dataType(value:String):void
		{
			_dataType = value;
		}


	}
}