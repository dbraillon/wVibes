package com.dbraillon.broadcast
{
	import flash.external.ExtensionContext;

	public class BroadcastInterface
	{
		private var context:ExtensionContext;
		
		public function BroadcastInterface()
		{
			if(!context)
			{
				context = ExtensionContext.createExtensionContext("com.dbraillon.broadcast", null);
			}
		}
		
		public function send(request:String, port:int):void
		{
			context.call("broadcast", request, port);
		}
	}
}