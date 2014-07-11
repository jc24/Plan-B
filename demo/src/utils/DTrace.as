package utils 
{
	/**
	 * ...
	 * @author 
	 */
	public class DTrace 
	{
		
		public function DTrace() 
		{
			
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