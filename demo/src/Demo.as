package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	
	[SWF(backgroundColor="#000000")]
	public class Demo extends Sprite
	{
		private var _starling:Starling
		public function Demo()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_starling = new Starling(Game,stage)
			_starling.start();
		}
	}
}