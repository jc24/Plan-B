package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import conf.Conf;
	
	import gamedata._G;
	
	import res.ResPool;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	
	import utils.Logger;

	public class Game extends Sprite
	{
		public function Game()
		{
			var textField:TextField = new TextField(400,300,"Welcome to Starling","SimSun",12,0xffffff)
			addChild(textField);
			
			test();
		}
		
		private function test():void
		{
			//测试配置表功能 注意 utf8
			Conf.initConf();
			
			//测试载入地图
			var tmx1:Object = _G.conf["mission"][10101];
			var tmxUrl:String = tmx1.sz_file_url
			trace(tmxUrl)
			loadXml(tmxUrl);
		}
		
		private function loadXml(url:String):void
		{
			var _loader:URLLoader = new URLLoader();
			// ver使用时间，确保每次随时更新下载配置文件
			_loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
				//KLogger.info("gs.conf IOError");
				Logger.info("load file:" + url + "  failed (" + e.target.bytesLoaded + "/" + e.target.bytesTotal + ")");
			} );
			_loader.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					//KLogger.info("load gs.conf success！");
					if (_loader.data != null)
					{
						// 加载配置文件
						var xmlConf:XML = new XML(_loader.data);
						ResPool.Files[url] = xmlConf;
						
					}
					else
					{
						trace("加载配置文件失败!");
					}
				});
			_loader.load(new URLRequest(url));
		}
	}
}