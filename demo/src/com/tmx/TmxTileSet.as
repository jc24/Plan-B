/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License. (Just like Flixel)
 * For questions mail me at lithander@gmx.de!
 ******************************************************************************/
package com.tmx 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class TmxTileSet
	{
		private var _tileProps:Array = [];
		private var _image:BitmapData = null;
		
		public var firstGID:int = 0;
		public var map:TmxMap;
		public var name:String;
		public var tileWidth:int;
		public var tileHeight:int;
		public var spacing:int;
		public var margin:int;
		public var swfSource:String = "";
		public var swfMiniSource:String = "";
		public var initialSource:String = "";
		public var imageSource:String;
		public var miniSource:String="";
		
		//available only after immage has been assigned:
		public var numTiles:int = 0xFFFFFF;
		public var numRows:int = 1;
		public var numCols:int = 1;
		
		public var width:int;
		public var height:int;
		public function TmxTileSet(source:XML, parent:TmxMap)
		{
			firstGID = source.@firstgid;

			imageSource = source.image.@source;
			
			
			map = parent;
			name = source.@name;
			tileWidth = source.@tilewidth;
			tileHeight = source.@tileheight;
			spacing = source.@spacing;
			margin = source.@margin;
			
			width = source.image.@width;
			height = source.image.@height;
			
			numCols = Math.floor(source.image.@width / tileWidth);
			numRows = Math.floor(source.image.@height / tileHeight);
			numTiles = numRows * numCols;
			
			//read properties
			for each(var node:XML in source.tile)
				if(node.properties[0])
					_tileProps[int(node.@id)] = new TmxPropertySet(node.properties[0]);
		}
		
		public function get image():BitmapData
		{
			return _image;
		}
		
		public function set image(v:BitmapData):void
		{
			_image = v;
			//TODO: consider spacing & margin
			numCols = Math.floor(v.width / tileWidth);
			numRows = Math.floor(v.height / tileHeight);
			numTiles = numRows * numCols;
		}
		
		public function hasGid(gid:int):Boolean
		{
			return (gid >= firstGID) && (gid < firstGID + numTiles);
		}
		
		public function fromGid(gid:int):int
		{
			return gid - firstGID;
		}
		
		public function toGid(id:int):int
		{
			return firstGID + id;
		}

		public function getPropertiesByGid(gid:int):TmxPropertySet
		{
			return _tileProps[gid - firstGID];	
		}
		
		public function getProperties(id:int):TmxPropertySet
		{
			return _tileProps[id];	
		}
		
		public function getRectByGid(gid:int):Rectangle
		{
			var id:int = gid - firstGID;
			return new Rectangle(int(id % numCols) * tileWidth, int(id / numCols) * tileHeight,tileWidth,tileHeight);
		}
		
		public function getRect(id:int):Rectangle
		{
			//TODO: consider spacing & margin
			return new Rectangle((id % numCols) * tileWidth, (id / numCols) * tileHeight,tileWidth,tileHeight);
		}
	}
}