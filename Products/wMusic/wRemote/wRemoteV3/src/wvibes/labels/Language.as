package wvibes.labels
{
	import mx.resources.ResourceManager;
	import mx.resources.IResourceManager;

	public class Language
	{
		public static const ENGLISH : int = 0;
		public static const FRENCH : int = 1;
		
		private var resourceManager:IResourceManager;
		
		public function Language()
		{
			resourceManager = ResourceManager.getInstance();
			resourceManager.localeChain = ["en_US"];
		}
		
		public function change(language:int):void
		{
			switch(language)
			{
				case ENGLISH:
					
					resourceManager.localeChain = ["en_US"];
					break;
				
				case FRENCH:
					
					resourceManager.localeChain = ["fr_FR"];
					break;
			}
		}
	}
}