/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License. (Just like Flixel)
 * For questions mail me at lithander@gmx.de!
 ******************************************************************************/
package com.tmx 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	import utils.Base64;

	public class TmxLayer
	{
		public var map:TmxMap;
		public var name:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var opacity:Number = 1;
		public var visible:Boolean;
		public var tileGIDs:Array;
		public var tileIndexs:Array;
		public var properties:TmxPropertySet = null;
		public var bEmpty:Boolean = false;
		//空层字符串
		public static const NULLBASE64:String = "eJztwTEBAAAAwqD1T20ND6AAAAAAAAAAAAAAAAAAAAAAgBcDRBAAAQ==";
		public function TmxLayer(source:XML, parent:TmxMap)
		{
			map = parent;
			name = source.@name;
			x = source.@x; 
			y = source.@y; 
			width = source.@width; 
			height = source.@height; 
			visible = !source.@visible || (source.@visible != 0);
			opacity = source.@opacity;
			
			
			//load properties
			var node:XML;
			for each(node in source.properties)
				properties = properties ? properties.extend(node) : new TmxPropertySet(node);
			
			//load tile GIDs
			tileIndexs = [];//存储有效gid
			tileGIDs = [];
			var data:XML = source.data[0];
			if(data)
			{
				var chunk:String = "";
				if(data.@encoding.length() == 0)
				{
					//create a 2dimensional array
					var lineWidth:int = width;
					var rowIdx:int = -1;
					for each(node in data.tile)
					{
						//new line?
						if(++lineWidth >= width)
						{
							tileGIDs[++rowIdx] = [];
							lineWidth = 0;
						}
						var gid:int = node.@gid;
						tileGIDs[rowIdx].push(gid);
					}
				}
				else if(data.@encoding == "csv")
				{
					chunk = data;
					//trace(chunk);
					tileGIDs = csvToArray(chunk, width);
				}
				else if(data.@encoding == "base64")
				{
					chunk = data;
					var compressed:Boolean = false;
					//trace(chunk);
					var time:Number = getTimer();
					
					if(data.@compression == "zlib")
					{
						compressed = true;
					}
					else if(data.@compression.length() != 0)
					{
						throw Error("TmxLayer - data compression type not supported!");
					}
					
					//for(var i:int = 0; i < 100; i++)
					tileGIDs = base64ToArray(chunk, width, compressed);	
					validateTile();

					
					//trace("tooked", getTimer() - time);
					
					//DTrace.traceex("tmxlayer:" + name + "|", tileGIDs);
				}
			}
		}
		
		//过滤无效的gid
		private function validateTile():void
		{
			for (var i:int = 0; i < height; i++)
			{
				for (var j:int = 0; j < width; j++)
				{
					var gid:int = tileGIDs[i][j];
					if (gid > 0)
					{
						tileIndexs.push( {x:j, y:i, gid:gid});
					}
				}
			}
		}
		
		public function toCsv(tileSet:TmxTileSet = null):String
		{
			var max:int = 0xFFFFFF;
			var offset:int = 0;
			if(tileSet)
			{
				offset = tileSet.firstGID;
				max = tileSet.numTiles - 1;
			}
			var result:String = "";
			for each(var row:Array in tileGIDs)
			{
				var chunk:String = "";
				var id:int = 0;
				for each(id in row)
				{
					id -= offset;
					if(id < 0 || id > max)
						id = 0;
					result += chunk;
					chunk = id+",";
				}
				result += id+"\n";	
			}
			return result;
		}
				
		/* ONE DIMENSION ARRAY
		public static function arrayToCSV(input:Array, lineWidth:int):String
		{
			var result:String = "";
			var lineBreaker:int = lineWidth;
			for each(var entry:uint in input)
			{
				result += entry+",";
				if(--lineBreaker == 0)
				{
					result += "\n";
					lineBreaker = lineWidth;
				}
			}
			return result;
		}
		*/
		
		public static function csvToArray(input:String, lineWidth:int):Array
		{
			var result:Array = [];
			var rows:Array = input.split("\n");
			for each(var row:String in rows)
			{
				var resultRow:Array = [];
				var entries:Array = row.split(",", lineWidth);
				for each(var entry:String in entries)
					resultRow.push(uint(entry)); //convert to uint
				result.push(resultRow);
			}
			return result;
		}
		
		public static function base64ToArray(chunk:String, lineWidth:int, compressed:Boolean):Array
		{
			var result:Array = [];
			var data:ByteArray = Base64.decode(chunk);
			if(compressed)
				data.uncompress();
			data.endian = Endian.LITTLE_ENDIAN;
			while(data.position < data.length)
			{
				var resultRow:Array = [];
				for(var i:int = 0; i < lineWidth; i++)
					resultRow.push(data.readInt())
				result.push(resultRow);
			}
			return result;
		}
		
		public static function isEmpty(source:XML):Boolean
		{
			var data:XML = source.data[0];
			var str:String = data;
			if(data.@encoding == "base64" && data.@compression == "zlib")
			{
				return str == NULLBASE64;
			}
			else
			{
				throw new Error("该函数只支持base64-zlib格式的判空!");
				return false;
			}
		}
	}
}