package utils 
{
	/**
	 * ...
	 * @author 
	 */
	public class PixelUtils 
	{
		private static const LOGIC_PIXEL:int = 1000;
		private static const LOGIC_PIXEL_DEC:Number = 1 / LOGIC_PIXEL;
		public function PixelUtils() 
		{
			
		}
		
		public static function toNormal(value:int):int
		{
			return int(value * LOGIC_PIXEL_DEC);
		}
		
		public static function toScale(value:int):int
		{
			return int(value * LOGIC_PIXEL);
		}
		
	}

}