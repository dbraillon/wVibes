package wvibes.connections
{
	import flash.net.SharedObject;

	public class Address
	{
		// server's address
		private var _url:String;
		private var _port:int;
		
		public function Address(url:String = null, port:int = 0)
		{
			_url = url;
			_port = port;
		}

		public function register():void
		{
			trace("+ Address.as : register : Register last url and port.");
			
			SharedObject.getLocal("address").data.url = url;
			SharedObject.getLocal("address").data.port = port;
		}
		
		// url getter
		public function get url():String
		{
			if(!_url)
			{
				_url = SharedObject.getLocal("address").data.url as String;
			}
			
			return _url;
		}
		
		// port getter
		public function get port():int
		{
			if(_port == 0)
			{
				_port = SharedObject.getLocal("address").data.port as int;
			}
			
			return _port;
		}
		
		public function toString():String
		{
			return "http://" + url + ":" + port + "/";
		}
	}
}