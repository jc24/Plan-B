/*******************************************************************************
 * Copyright (c) 2010 by Thomas Jahn
 * This content is released under the MIT License. (Just like Flixel)
 * For questions mail me at lithander@gmx.de!
 ******************************************************************************/
package com.tmx 
{
	import flash.xml.XMLNode;
	public class TmxMap
	{
		public var version:String; 
		public var orientation:String;
		public var width:uint;   //格子数量
		public var height:uint; 
		public var tileWidth:uint; //每个大小
		public var tileHeight:uint;
		
		public var properties:TmxPropertySet = null;
		public var layers:Object = {};
		public var tileSets:Object = { };
		public var m_tileSetCount:int = 0;//资源数量
		public var objectGroups:Object = {};
		
		public var m_url:String;
		public var renderSeq:Vector.<String>;//各个层的顺序
		public var layerCount:int;
		public function TmxMap(source:XML,disableLayers:Object=null)
		{
			//map header
			version = source.@version ? source.@version : "unknown"; 
			orientation = source.@orientation ? source.@orientation : "orthogonal";
			width = source.@width;
			height = source.@height;
			tileWidth = source.@tilewidth;
			tileHeight = source.@tileheight;
			
			//生成渲染层的顺序表
			renderSeq =  genLayerSeq(source,disableLayers);
			
			//read properties
			for each(node in source.properties)
			{
				properties = properties ? properties.extend(node) : new TmxPropertySet(node);
			}
				
			//load tilesets
			var node:XML = null;
			for each(node in source.tileset)
			{
				tileSets[node.@name] = new TmxTileSet(node, this);
				m_tileSetCount++;
			}
			
			//load layer
			for each(node in source.layer)
			{
				//过滤无效的、空的层
				if ((disableLayers == null || disableLayers[node.@name] == null) && !TmxLayer.isEmpty(node))
				{
					//DTrace.traceex("layer name:" + node.@name);
					layers[node.@name] = new TmxLayer(node, this);
				}
			}
				
			//load object group
			for each(node in source.objectgroup)
			{
				if(disableLayers == null || disableLayers[node.@name] == null)
				{
					//DTrace.traceex("objgroup name:" + node.@name);
					objectGroups[node.@name] = new TmxObjectGroup(node, this);
				}
			}
		}
		
		//生成各个层的渲染顺序
		public function genLayerSeq(source:XML,filterName:Object=null):Vector.<String>
		{
			var namelist:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < source.*.length(); i++)
			{
				var xml:XML = source.*[i];
				var tagname:String = xml.name();
				if (tagname == "layer")
				{
					if ((filterName == null || filterName[xml.@name] == null) &&
						!TmxLayer.isEmpty(xml))
					{
						namelist.push(String(xml.@name));
						layerCount++;
					}
				}
				else if (tagname == "objectgroup")
				{
					if (filterName == null || filterName[xml.@name] == null)
					{
						namelist.push(String(xml.@name));
						layerCount++;
					}
				}
			}
			//DTrace.traceex("genLayerSeq::", namelist);
			return namelist;
		}
		
		public function getTileSet(name:String):TmxTileSet
		{
			return tileSets[name] as TmxTileSet;
		}
		
		public function getLayer(name:String):TmxLayer
		{
			return layers[name] as TmxLayer;
		}
		
		public function getObjectGroup(name:String):TmxObjectGroup
		{
			return objectGroups[name] as TmxObjectGroup;	
		}			
		
		//works only after TmxTileSet has been initialized with an image...
		public function getGidOwner(gid:int):TmxTileSet
		{
			var last:TmxTileSet = null;
			for each(var tileSet:TmxTileSet in tileSets)
			{
				if(tileSet.hasGid(gid))
					return tileSet;
			}
			return null;
		}
		
	}
}
