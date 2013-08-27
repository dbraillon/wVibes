package 
{
	import flash.events.EventDispatcher;
	import connections.Connection;

	public class Model extends EventDispatcher
	{
		private static var instance:Model;
		
		public static function getInstance():Model
		{
			if(!instance)
			{
				instance = new Model();
			}
			
			return instance;
		}
		
		
		public var connection:Connection;
		
		public function Model()
		{
			// Initialize here...
			connection = new Connection();
		}
	}
}