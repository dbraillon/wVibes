package com.dbraillon.pocspotifymobile.events
{
	import flash.events.Event;

	public class ResponseEvent extends Event
	{
		private var _response:String;
		private var _responseType:String;
		
		public function ResponseEvent(_type:String, _bubbles:Boolean = true, _cancelable:Boolean = true)
		{
			super(_type, _bubbles, _cancelable);
		}

		override public function clone():Event
		{
			var event:ResponseEvent = new ResponseEvent(type, bubbles, cancelable);
			event.response = response;
			event.responseType = responseType;
			
			return event as Event;
		}
		
		
		public function get response():String
		{
			return _response;
		}
		
		public function set response(value:String):void
		{
			_response = value;
		}

		public function get responseType():String
		{
			return _responseType;
		}

		public function set responseType(value:String):void
		{
			_responseType = value;
		}

	}
}