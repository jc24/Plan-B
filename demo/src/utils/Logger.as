package utils
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	
	public class Logger
	{
		public static const LOG_ERROR:int = 1;
		public static const LOG_WARN:int = 2;
		public static const LOG_INFO:int = 3;
		public static const LOG_DEBUG:int = 4;
		
		private static var _externOutput:Boolean = false;
		private static var _externOutputCallback:Function = null;
		private static var _isConsoleLogEnable:Boolean = false;
		
		private static var _logLevel:int = LOG_INFO;
		private static var _logTime:String = null;
		private static var _prefix:String = null;
		
		activate();
		
		public function Logger()
		{
		}
		
		public static function activate():void
		{
			var now:Date = new Date();
			_logTime = FUtils.formatTime(now);
		}
		
		public static function set prefix(prefix:String):void
		{
			_prefix = prefix;
		}
		
		public static function set externOutputCallback(callback:Function):void
		{
			_externOutputCallback = callback;
		}
		
		public static function debug(msg:String):void
		{
			if (_logLevel >= LOG_DEBUG)
				output(LOG_DEBUG, msg, _externOutput);
		}
		
		public static function info(msg:String, obj:* = null, tracestack:Boolean=false):void
		{
			if (_logLevel >= LOG_INFO)
			{
				var str:String = msg;
				if (obj != null && typeof(obj) == "object")
				{
					str += toStringEx(obj)
				}
				if (tracestack) str += getTraceStack();
				output(LOG_INFO, str, _externOutput);
			}
		}
		
		public static function warn(msg:String):void
		{
			if (_logLevel >= LOG_WARN)
				output(LOG_WARN, msg, _externOutput);
		}
		
		public static function error(msg:String):void
		{
			if (_logLevel >= LOG_ERROR)
			{
				msg += getCaller()
				output(LOG_ERROR, msg, true);
			}
		}
		
		public static function getCaller():String
		{
			var error:Error = new Error();
			var stackText:String = error.getStackTrace();
			if (stackText)
			{
				var fileInfo:Array = stackText.match(/(\w+\.\w+:\d+)/g);
				stackText = fileInfo.join("/");
			}
			return stackText;
		}	
		
		private static function output(type:int, msg:String, externOutput:Boolean):void
		{
			var title:String = _logTime;
			switch (type) 
			{
				case LOG_DEBUG:
					title += "[DEBUG]";
					break;
				case LOG_INFO:
					title += "[INFO]";
					break;
				case LOG_WARN:
					title += "[WARN]";
					break;
				case LOG_ERROR:
					title += "[ERROR]";
					break;
				default:
					assert(false);
					break;
			}
			
			msg = _prefix ? title + _prefix + msg : title + msg;
			//if (_isConsoleLogEnable && ExternalInterface.available)
			//{
				//ExternalInterface.call('console.log', msg);
			//}
			
			if (Capabilities.isDebugger)
			{
				trace(msg);
			}
			
			if (_externOutputCallback != null)
			{
				_externOutputCallback.call(null, type, msg);
			}
		}
		
		public static function throwError(error:Error):void
		{
			output(LOG_ERROR, "throw error " 
				+ error.name + ", "
				+ error.errorID + ", "
				+ error.message + ", "
				+ error.getStackTrace() + ""
				+ error.toString(), 
				true
			);
			if (Capabilities.isDebugger)
			{
				throw error;
			}
		}
		
		public static function assert(expression:Boolean, description:String = null, errorID:uint = 0):void
		{
			if (!expression)
			{
				throwError(new Error("Check failed!! " + description, errorID));
			}
		}
		
		public static function set isConsoleLogEnable(value:Boolean):void
		{
			_isConsoleLogEnable = value;
		}
		
		public static function set logLevel(value:int):void
		{
			_logLevel = value;
		}
		
		public static function set externOutput(value:Boolean):void
		{
			_externOutput = value;
		}
		
		public static function toStringEx(obj:*, len:int = 0):String
		{
			var ret:String = "";
			var pre:String = "";
			for (var i:int = 0; i < len; i++)
				pre += "\t";
			
			if (typeof(obj) == "object" && obj != null)
			{
				if (len > 5)
					return "\t{ ... }";
				var t:String = ""
				var keys:Array = [];
				for (var k1:String in obj)
				{
					keys.push(k1);
				}
				keys.sort();
				for each (var k2:String in keys)
				{
					t += "\n\t" + pre + k2.toString() + ":"
					t += toStringEx(obj[k2], len + 1);
				}
				if (t == "")
				{
					ret += pre + "{ }\t" + obj;
				}
				else
				{
					if (len > 0)
						ret += "\t" + (obj is Array ? "[Array]" : obj);
					ret += pre + "{" + t + "\n" + pre + "}"
				}
			}
			else
			{
				ret += pre + obj + "\t(" + typeof(obj) + ")"
			}
			return ret;
		}
		
		public static function getTraceStack():String
		{
			var stack:String = "";
			try
			{
				throw new Error("debug trace")
			}
			catch (e:Error)
			{
				stack = e.getStackTrace();
			}
			return stack;
		}
		
	}
}