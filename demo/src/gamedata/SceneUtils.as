package gamedata 
{
	import com.tmx.TmxMap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import map.Camera;
	import map.collid.MapTree;
	import map.collid.WalkHelp;
	import utils.PixelUtils;
	/**
	 * ...
	 * @author 
	 */
	public class SceneUtils 
	{
		//如果该值大于0，就使用固定的屏幕尺寸，否则屏幕尺寸就跟着窗口大小进行变化
		public  static const FIXVIEWWIDTH:int = 13840;
		public  static const FIXVIEWHEIGHT:int = 7200;		
		
		public static var mMapId:int;
		public static var mStageId:int;
		public static var mMapName:String;
		public static var mWorld:int = 0;
		
		// 当前屏幕相对于舞台的坐标
		public static var mViewx:int = 0;
		public static var mViewy:int = 0;		
		
		//每屏格子数
		public static var mViewCols:int;
		public static var mViewRows:int;
		
		//地图尺寸
		public  static var mMapWidth:int = 3520;
		public  static var mMapHeight:int = 1920;
		
		
		public static  var mMapWidthLogic:int = 0;
		public  static var mMapHeightLogic:int = 0;
		
		//格子大小
		public  static var mGridWidth:int  = 36;
		public  static var mGridHeight:int = 36;
		
		//格子行列数
		public  static var mMapCols:int = 88;
		public  static var mMapRows:int = 48;
		
		private static var mPos:Point = new Point();
		public static var mTree:MapTree;		
		public static var mCamera:Camera;
		public static var mWalk:WalkHelp;
		public static var mTmx:TmxMap;
		public static var mViewRect:Rectangle;
		
		public static var mNow:uint;
		public static var mDeltaTick:uint;
		public static var mLastTick:uint;
		
		public static const ZOMBIE_FLIP:Object  = {
			6:2,
			7:3,
			8:4
		}
		public static const DIRECTION_TRANS:Object = //8方向的怪，上下方向用偏左或偏右代替
		{
			1: [ 2, 8 ], //上方向1映射到方向偏左2，偏右8
			5: [ 4, 6 ]  //下方向5映射到方向偏左4， 偏右6
		};
		
		public static function screen2map(x:int, y:int):Point
		{			
			mPos.x = PixelUtils.toScale(x + mViewRect.x - mViewx);
			mPos.y = PixelUtils.toScale(y + mViewRect.y - mViewy);
			return mPos;
		}
		
		public static function screen2mapNoScale(x:int, y:int):Point
		{			
			mPos.x = x + mViewRect.x - mViewx;
			mPos.y = y + mViewRect.y - mViewy;
			return mPos;
		}
		
		public static function map2screen(x:int, y:int):Point
		{
			mPos.x = PixelUtils.toNormal(x) - mViewRect.x + mViewx;
			mPos.y = PixelUtils.toNormal(y) - mViewRect.y + mViewy;
			return mPos;
		}		
		
	}

}