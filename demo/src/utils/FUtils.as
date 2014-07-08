package utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class FUtils
	{	
		public static function setBitMark(set:Boolean, mark:uint, flag:uint):uint
		{
			if (set)
			{
				mark |= flag;
			}
			else
			{
				mark &= ~flag;
			}
			return mark;
		}
		
		public static function isMarked(mark:uint, flag:uint):Boolean
		{
			return (mark & flag) != 0;
		}
		
		public static function normpath(url:String):String
		{
			return url.replace(/[\/\\]+/g, "/");
		}
		
		public static function length(obj:*):int
		{
			var len:int = 0;
			if (obj is String)
				len = (obj as String).length;
			else if (obj is ByteArray)
				len = (obj as ByteArray).length;
			else if (obj is Array)
				len = (obj as Array).length;
			else if (obj is Dictionary)
				for (var key:String in obj)
					len++;
			
			return len;
		}
		
		public static function formatTime(time:Date):String
		{
			var getNumber:Function = function(value:Number, length:int):String
			{
				var perfix:String = "00000000";
				var text:String = value.toString();
				if (length > text.length) {
					text = perfix.substr(0, length - text.length) + text;
				}
				return text;
			}
			
			var text:String = getNumber(time.fullYear, 4);
			text += getNumber(time.month, 2);
			text += getNumber(time.date, 2);
			text += "-";
			text += getNumber(time.hours, 2);
			text += getNumber(time.minutes, 2);
			text += getNumber(time.seconds, 2);
			
			return text; 
		}
		
		public static function getVectorElementType(vector:*):Class
		{
			var vectorType:String = getQualifiedClassName(vector);
			var perfix:String = "Vector.<";
			var index:int = vectorType.indexOf(perfix) + perfix.length;
			var length:int = vectorType.lastIndexOf(">") - index;
			var type:String = vectorType.substr(index, length);
			return getDefinitionByName(type) as Class;
		}
		
		public static function getLength(map:Dictionary):int
		{
			var length:int = 0;
			for (var key:String in map)
			{
				length++;
			}
			return length;
		}
		
		public static function hash(path:String):uint
		{
			var tempValueB:uint = 378551;
			var tempValueA:uint = 63689;
			var result:uint = 0;
			for (var i:int = 0; i < path.length; i++)
			{
				result = uint(result * tempValueA) + path.charCodeAt(i);
				tempValueA = tempValueA * tempValueB;
			}
			return result;
		}
		
		public static function copyObject(src:Object, dst:Object):void
		{
			for (var key:String in src)
			{
				dst[key] = src[key];
			}
		}
		
		public static function writeBytes(bytes:ByteArray, src:ByteArray):void
		{
			bytes.writeShort(src.bytesAvailable);
			bytes.writeBytes(src);
		}
		
		public static function readBytes(bytes:ByteArray, to:ByteArray):void
		{
			var length:int = bytes.readShort();
			bytes.readBytes(to, 0, length);
		}
		
		
		public static function inRange(value:Number, min:Number, max:Number):Number
		{
			if (value < min)
				value = min;
			
			if (value > max)
				value = max;
			
			return value;
		}
		
		
		public static function dumpBytes(bytes:ByteArray, maxLength:int = 0):String
		{
			var str:String = "[" + bytes.length + "]";
			var position:int = bytes.position;
			bytes.position = 0;
			if (maxLength == 0 || maxLength > bytes.bytesAvailable)
				maxLength = bytes.bytesAvailable;
			
			while (maxLength--)
			{
				var byte:int = bytes.readByte();
				byte &= 0xFF;
				str += byte.toString(16) + " ";
			}
			bytes.position = position;
			
			return str;
		}
		
		public static function formatSignedInteger(integer:int):String
		{
			return integer > 0 ? "+" + integer : integer.toString();
		}
		
		public static function formatHTMLText(text:String, newline:Boolean = false, fontSize:int = 12, fontColor:uint = 0xFFFFFF, bold:Boolean = false, italic:Boolean = false):String
		{
			var prefix:String = "<font size=" + fontSize + " color='#" + fontColor.toString(16) + "'>";
			
			var suffix:String = "</font>";
			if (bold)
			{
				prefix = "<b>" + prefix;
				suffix = suffix + "</b>";
			}
			
			if (italic)
			{
				prefix = "<i>" + prefix;
				suffix = suffix + "</i>";
			}
			
			var output:String = newline ? "<br/>" : "";
			
			var textArr:Array = text.split(/\\n|<br>|<br\/>/);
			for (var i:int = 0; i < textArr.length; ++i)
			{
				output += prefix + textArr[i] + suffix;
				if (i < textArr.length - 1)
					output += "<br/>";
			}
			
			return output;
		}
		
		public static function formatHTMLImage(url:String, width:int, height:int):String
		{
			return "<img src='" + url + "' width=" + width + " height=" + height + " />";	
		}
		
		public static function appendHTMLNewline(htmlText:String, count:int = 1):String
		{
			for (var i:int = 0; i < count; i++)
			{
				htmlText += "<br/>";
			}
			return htmlText;
		}
		
		public static function int2str(value:int, len:int):String
		{
			var v:String = value.toString();
			if (v.length > len)
			{
				v = v.substr(v.length - len, len);
			}
			else if (v.length < len)
			{
				for (var i:int = 0; i < len - v.length; i++)
				{
					v = "0" + v;
				}
			}
			return v;
		}
		
		public static function splitInteger(value:int):String
		{
			var text:String = null;
			while (value > 0)
			{
				var residue:String = (value % 1000).toString();
				value /= 1000;
				
				if (value > 0)
				{
					switch (residue.length)
					{
						case 1:
							residue = "00" + residue;
							break;
						case 2:
							residue = "0" + residue;
					}
				}
				
				text = residue + (text ? "," + text : "");
				
			}
			return text ? text : "0";
		}
	}
}