package conf
{
	import flash.utils.ByteArray;
	
	import gamedata._G;
	
	import utils.TabReader;
	
	public class Conf
	{
		//地图索引
		[Embed(source = "/../Release/conf/mission.tab", mimeType = "application/octet-stream")] private static const mission_tab:Class;
		public function Conf()
		{
		}
		
		public static function initConf():void
		{
			_G.conf["mission"]  = TabReader.readBaseByteData( new mission_tab() as ByteArray );
			var obj:Object = _G.conf["mission"];
			var i:int = 0;	
		}
	}
}