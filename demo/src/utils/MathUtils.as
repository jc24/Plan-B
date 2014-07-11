package utils 
{
	/**
	 * ...
	 * @author lq
	 */
	public class MathUtils 
	{
		
		public function MathUtils() 
		{
			
		}
		
		
		public static function randRange(min:Number, max:Number):Number 
		{
			if (min == max) return min;
			var randomNum:Number = Math.random() * (max - min + 1) + min;
			return randomNum;
		}
		
        public static function readableBytes(bytes:Number):String
        {
            var s:Array = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB'];
            var exp:Number = Math.floor(Math.log(bytes)/Math.log(1024));
            return  (bytes / Math.pow(1024, Math.floor(exp))).toFixed(2) + " " + s[exp];
        }
		
		public static function calcAngle(x1:int, y1:int, x2:int, y2:int):int
		{
			var dx:int = x2 - x1;
			var dy:int = y2 - y1;
			var radians:Number = Math.atan2(dy, dx);
			var angle:Number = Math.round(radians * 180 / Math.PI);
			return angle;
		}
		
		public static function calcRadians(x1:int, y1:int, x2:int, y2:int):Number
		{
			var dx:int = x2 - x1;
			var dy:int = y2 - y1;
			var radians:Number = Math.atan2(dy, dx);
			return radians;
		}
		
		public static function angleToRadians(angle:int):Number
		{
			return angle * Math.PI / 180;
		}
		
		public static function calcDist(x1:int, y1:int, x2:int, y2:int):int
		{
			var dx:int = x2 - x1;
			var dy:int = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
	}

}