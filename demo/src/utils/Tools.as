package utils 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author ...
	 */
	public class Tools 
	{
		
		public static function getObjectIsNull(object:Object):Boolean
		{
			var count:int = 0;
			for each(var o:Object in object)
			{
				count++;
			}
			if (count > 0) return false;
			return true;
		}
		public static function readParam(strParam:String):Object
		{
			var pattern1:RegExp = /{/;
			var pattern2:RegExp = /}/;
			strParam = strParam.replace(pattern1, "");
			strParam = strParam.replace(pattern2, "");
			var tempConf:Array = strParam.split(",");
			var objConf:Object = { };

			for (var i:int = 0; i < tempConf.length; i++)
			{
				var tempParam:Array = (tempConf[i] as String).split("=");
				if (tempParam.length != 2)
					continue;

				tempParam[0] = skipStrSpace(tempParam[0]);
				tempParam[1] = skipStrSpace(tempParam[1]);

				if ((tempParam[0] as String).substr(0, 2) == "sz")
				{
					objConf[tempParam[0]] = tempParam[1];
				}
				else
				{
					objConf[tempParam[0]] = parseInt(tempParam[1]);
				}
			}

			return objConf;
		}
		
		private static function skipStrSpace(value:String):String
		{
			if (value.charAt(0) == ' ')
			{
				value = value.substring(1, value.length);
			}
			if (value.charAt(value.length - 1) == ' ')
			{
				value = value.substring(0, value.length - 1);
			}

			return value;
		}
		
		
		/**
		 * 全部替换指定的字符串（区分大小写）。如要替换的字符串不在源字符串中则返回源字符串。
		 * @param $str 源总字符串
		 * @param $old 要替换的字符串
		 * @param $new 替换成的新字符串
		 * @return (String) 替换后的新字符串
		 * */
		public static function replaceStr($str:String, $old:String, $new:String):String
		{
			var str:String = "";
			var r:Array = $str.split($old);
			var n:int = r.length;
			var i:int = 0;
			for each(var s:String in r)
			{
				if(i < n - 1)
				{
					str += s + $new;
				}
				else
				{
					str += s;
				}
				i++;
			}
			return str;
		}
		
		public static function escapeHtml(s:String):String
		{
			//Replace & < > " '
			return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;")
				.replace(/'/g, "&apos;");
		}		
		
		//简单克隆，适用于无嵌套表(即表内部无引用)的情况
		public static function simpleClone(obj:Object):Object
		{
			var newobj:Object = { };
			for (var k:* in obj) {
				newobj[k] = obj[k];	
			}
			return newobj;
		}
		
		public static function deep_clone(obj:Object):* 
		{
            var toobj:ByteArray = new ByteArray();
            toobj.writeObject(obj);
            toobj.position = 0;
            return toobj.readObject();
		}
		
				
		public static function getDefaultValue(value:*, defaultValue:Number):Number
		{
			if (value == null || isNaN(value) || value == undefined)
				return defaultValue;
			return Number(value);
		}
	}

}