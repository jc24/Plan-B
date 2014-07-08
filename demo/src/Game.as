package
{
	import starling.display.Sprite;
	import starling.text.TextField;
	import conf.Conf;

	public class Game extends Sprite
	{
		public function Game()
		{
			var textField:TextField = new TextField(400,300,"Welcome to Starling","SimSun",12,0xffffff)
			addChild(textField);
			
			Conf.initConf();
		}
	}
}