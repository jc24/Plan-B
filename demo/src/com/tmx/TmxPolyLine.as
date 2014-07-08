/*******************************************************************************
 * Copyright (c) 2012 by dengzhihui
 * This content is released under the MIT License. (Just like Flixel)
 * For questions mail me at dengzhihui.com@gmail.com!
 ******************************************************************************/
package com.tmx 
{
	import flash.geom.Point;
	public class TmxPolyLine
	{
		public var object:TmxObject;
		private var polylinestr:String;
		public var points:Array = null;
		public function TmxPolyLine(source:XML, parent:TmxObject)
		{
			object = parent;
			points = new Array();
			var node:XML;
			for each(node in source.polyline)
			{
				polylinestr = node.@points;
			}
			
			if (polylinestr == null || polylinestr.length == 0) 
			{
				polylinestr = "";
				points = new Array();
				return;
			}
			
			points.push(new Point(-100, -100));
			var arr:Array = polylinestr.split(" ");
			for each(var sznode:String in arr)
			{
				if (sznode != "" && sznode != ",")
				{
					var aPoint:Array = sznode.split(",");
					points.push(new Point(aPoint[0], aPoint[1]));
				}
			}			
		}
	}
}