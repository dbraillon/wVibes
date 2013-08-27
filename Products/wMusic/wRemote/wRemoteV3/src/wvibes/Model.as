package wvibes
{
	import flash.events.EventDispatcher;
	
	import wvibes.connections.services.Connection;
	import wvibes.labels.Language;

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
		
		
		public var language:Language;
		public var connection:Connection;
		
		public function Model()
		{
			// Initialize here...
			language = new Language();
			connection = new Connection();
		}
	}
}