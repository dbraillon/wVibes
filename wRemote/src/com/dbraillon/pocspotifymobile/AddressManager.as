package com.dbraillon.pocspotifymobile
{
	import flash.utils.getQualifiedClassName;
	
	public class AddressManager
	{
		private var _firstPart:Array;
		
		private var _secondPartStart:int;
		private var _secondPartLast:int;
		private var _currentSecond:int;
		
		private var _thirdPartStart:int;
		private var _thirdPartLast:int;
		private var _currentThird:int;
		
		private var _first:String;
		private var _second:int;
		private var _third:int;
		
		public function AddressManager(firstPart:String, secondPartStart:int, secondPartLast:int, thirdPartStart:int, thirdPartLast:int)
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "AddressManager(" + firstPart + ", " + secondPartStart + ", " + secondPartLast + ", " + thirdPartStart + ", " + thirdPartLast + ")");
			
			_firstPart = new Array();
			
			_first = null;
			_second = -1;
			_third = -1;
			
			addFirstPartAddress(firstPart);
			addSecondPartAddress(secondPartStart, secondPartLast);
			addThirdPartAddress(thirdPartStart, thirdPartLast);
		}
		
		public function addFirstPartAddress(firstPart:String):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addFirstPartAddress(" + firstPart + ")");
			
			_firstPart.push(firstPart);
		}
		
		public function addSecondPartAddress(secondPartStart:int, secondPartLast:int = -1):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addSecondPartAddress(" + secondPartStart + ", " + secondPartLast + ")");
			
			_secondPartStart = secondPartStart;
			_secondPartLast = (secondPartLast != -1) ? secondPartLast : secondPartStart;
		}
		
		public function addThirdPartAddress(thirdPartStart:int, thirdPartLast:int = -1):void
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "addThirdPartAddress(" + thirdPartStart + ", " + thirdPartLast + ")");
			
			_thirdPartStart = thirdPartStart;
			_thirdPartLast = (thirdPartLast != -1) ? thirdPartLast : thirdPartStart;
		}
		
		public function nextAddress():String
		{
			Log.write(Log.LEVEL_2, flash.utils.getQualifiedClassName(this), "nextAddress()");
			
			var s:String;
			
			if(_first == null && _second == -1 && _third == -1)
			{
				_first = _firstPart.shift();
				_second = _secondPartStart;
				_third = _thirdPartStart;
				
				s = _first + "." + _second + "." + _third; 
				
				return s;
			}
			
			_third++;
			if(_third > _thirdPartLast)
			{
				_third = _thirdPartStart;
				_second++;
			}
			
			if(_second > _secondPartLast)
			{
				_second = _secondPartStart;
				_first = _firstPart.shift();
			}
			
			if(_first == null)
			{
				return null;
			}
			
			s = _first + "." + _second + "." + _third;
			
			return s;
		}
	}
}