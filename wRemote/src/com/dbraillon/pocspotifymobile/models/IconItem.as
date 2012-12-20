package com.dbraillon.pocspotifymobile.models
{
	public class IconItem
	{
		private var _label:String;
		private var _message:String;
		private var _icon:String;
		private var _type:String;
		
		public function IconItem(label:String, message:String, icon:String, type:String)
		{
			_label = label;
			_message = message;
			_icon = icon;
			_type = type;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			_message = value;
		}

		public function get icon():String
		{
			return _icon;
		}

		public function set icon(value:String):void
		{
			_icon = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}


	}
}