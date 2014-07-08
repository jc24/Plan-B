package utils
{
	import com.adobe.serialization.lua.LUALIB;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lihongyi
	 */
	public class TabReader
	{
		public function TabReader() 
		{
		}
		
		public static function readBaseByteData(byteData:ByteArray):Object
		{
			var dataLen:int = byteData.length;
			if (byteData[0] == 0xEF)
			{
				// 发现有Bom格式头，直接跳过
				byteData.readShort();
				byteData.readByte();
				dataLen -= 3;
			}
			/*
			if (byteData[0] != 0xEF)
			{
				throw new Error("不是合法的UTF-8文件格式>>" + str);
			}*/
			
			var str:String = byteData.readMultiByte(dataLen, "utf-8");
			
			return readBaseTabString(str);
		}
		
		public static function readBaseTabString(str:String):Object
		{
			var data:Object = { };
			var rows:Array = str.split("\r\n");
			var colNames:Array = null;
			for (var i:int = 0; i < rows.length; i++)
			{
				var row:String = rows[i];
				if (row == "" || row.charAt(0) == "#") continue;
				
				var col:Array = row.split("\t");
				if (colNames == null)
				{
					colNames = col;
				}
				else
				{
					var item:Object = { }
					var itemId:int = int(col[0]);
					for (var j:int = 0; j < col.length; j++)
					{
						var colData:String = col[j];
						if (colData.charAt(0) == '"' && colData.charAt(colData.length - 1) == '"')
						{
							// 增加对双引号的支持，兼容Excel导出
							col[j] = colData.substring(1, colData.length - 2);
						}
						if(colNames[j].substr(0, 2) == "sz")
							item[colNames[j]] = col[j];
						else
						{
							var intValue:Number = col[j] == "" ? 0 : col[j];
							item[colNames[j]] = intValue;
						}
					}
					if (data[itemId.toString()] != null) throw new Error("tab中 id 重复 id:" + itemId + "\r\n" + str);
					data[itemId.toString()] = item;
				}
			}
			return data;
		}
		
		public static function isAs3Array(obj:Object):Boolean
		{
			var i:int = 0;
			for each(var v:Object in obj) i++;
			if (i == 0) return false;
			
			for (var n:int = 0; n < i; n++)
			{
				if (obj[n] == null) return false;
			}
			return true;
		}
		
		public static function tryTransAs3Array(obj:Object):Object
		{
			if (isAs3Array(obj))
			{
				var arr:Array = [];
				for each(var v:Object in obj)
					arr.push(v);
				//trace("转换成数组:" + DTrace.toStringEx(arr)+"   ->"+DTrace.toStringEx(obj));
				return arr;
			}
			else
				return obj;
		}
		
		public static function loadStringC(tbl:Object, tokey:String, srckey:String, isClon:Boolean=false):Object
		{
			if (!tbl[tokey]) {
				tbl[tokey] = loadString(tbl[srckey]);
			}
			
			if (!isClon) {
				return tbl[tokey];				
			}
			else {
				var ret:Object = { }
				for (var k:* in tbl[tokey]) {
					ret[k] = tbl[tokey][k];
				}
				return ret;
			}
		}

		public static function loadString(str:String):Object
		{
			var i:int = 0;
			var obj:Object;
			if (str == "" || str == null) return obj;
			else {
				var real_str:String = ""
				for (i = 0; i < str.length; i++)
				{
					var c:String = str.charAt(i);
					if (c != " ") real_str += c;
				}
				if (real_str.charAt(0) == '{') {
					obj =  LUALIB.decode(real_str);
					return tryTransAs3Array(obj);	
				}
				else {
					throw new Error("不是表字符串" + str);
					return null;
				}
			}
			
			//先清掉一次前后括号
			str = str.substring(1);
			str = str.substring(0, str.length - 1);
			if (str.charAt(0) == '{')
			{	
				//拆前后括号一组存一次
				var tempArray:Array = [];
				var tempStack:Array = [];
				for (i = 0; i < str.length; i++)
				{
					if (str.charAt(i) == '{')
					{
						tempStack.push(i);
					}
					else if (str.charAt(i) == '}')
					{
						tempStack.push(i);
						tempArray.push(str.substring(tempStack[0], tempStack[1] + 1));
						tempStack = [];		//清空栈
					}
				}
		
				
				for (i = 0; i < tempArray.length; i++)
				{
					tempArray[i] = skipStrSpace(tempArray[i]);		//去前后空格
					var tempObj:Object = readParam(tempArray[i]);
					obj[i] = tempObj;
				}
			}
			else
			{
				obj = readParam(str);
			}
			return obj;
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
		
		public static function readParam(strParam:String):Object
		{
			var pattern1:RegExp = /{/;
			var pattern2:RegExp = /}/;
			strParam = strParam.replace(pattern1, "");
			strParam = strParam.replace(pattern2, "");
			var tempConf:Array = strParam.split(",");
			var objConf:Object = { };

			for (var i:int = 0; i < tempConf.length; i++){
				var tempParam:Array = (tempConf[i] as String).split("=");
				if (tempParam.length != 2){//TODO:没有"="应该是数组.lq
					//continue;
					var obj:Object = skipStrSpace(tempConf[i]);
					if(obj!="") objConf[i] = obj;
				}
				else{
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
			}
			return objConf;
		}
				//解析嵌套的object
		public static function readParamEx(strParam:String):Object
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
				if (tempParam.length > 2) {
					tempParam[0] = skipStrSpace(tempParam[0]);
					var str:String = skipStrSpace(tempParam[1]);
					for (var j:int = 2; j < tempParam.length; j++)
					{
						str = str + "=" + skipStrSpace(tempParam[j]);
					}
					tempParam[1] = readParamEx(str);
				}else
				{
					tempParam[0] = skipStrSpace(tempParam[0]);
					tempParam[1] = skipStrSpace(tempParam[1]);
				}


				objConf[tempParam[0]] = tempParam[1];
			}
			return objConf;
		}
	}
}