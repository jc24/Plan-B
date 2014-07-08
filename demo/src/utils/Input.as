package utils 
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author 
	 */
	public class Input 
	{
		private static var _mKeysDown:Dictionary = new Dictionary(true);
		private static var _mouseDown:Boolean = false;
		public function Input() 
		{
			
		}
		
		public static function onMouseUp(e:MouseEvent):void
		{
			_mouseDown = false;
		}
		
		public static function onMouseDown(e:MouseEvent):void
		{
			_mouseDown = true;
		}
		
		public static function onKeyDown(e:KeyboardEvent):void
		{
			_mKeysDown[e.keyCode] = true;
		}
		
		public static function onKeyUp(e:KeyboardEvent):void
		{
			delete _mKeysDown[e.keyCode];
		}
		
		public static function clearKey():void
		{
			_mKeysDown = new Dictionary(true);
		}
		
		public static function isDown(code:int):Boolean
		{
			return _mKeysDown[code] != null;
		}
		
		public static function get mouseDown():Boolean
		{
			return _mouseDown;
		}
	}

}