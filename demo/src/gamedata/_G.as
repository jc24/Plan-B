package gamedata 
{
	import events.FEventManager;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author 
	 */
	public class _G 
	{
		public static var conf:Object = { };
		public static var data:Object = { };
		public static var event:FEventManager = new FEventManager();
		public static var receiver:EventDispatcher = new EventDispatcher;
		public static var stage:Stage;
		public static var localVar:SharedObject;
		public static var vars:Object = { };
		public static function getRealUrl(url:String):String
		{
			return url;
		}
		
		public static function getFullPath(url:String):String
		{
			return url;
		}
		
		public static function getUrlHost(fullpath:String):String 
		{
			return fullpath;
		}
	}

}