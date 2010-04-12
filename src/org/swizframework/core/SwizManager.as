package org.swizframework.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.utils.UIDUtil;
	
	public class SwizManager
	{
		public static var swizzes:Array = [];
		public static var wiredViews:Array = [];
		
		public static function addSwiz( swiz:ISwiz ):void
		{
			swizzes.push( swiz );
		}
		
		public static function removeSwiz( swiz:ISwiz ):void
		{
			swizzes.splice( swizzes.indexOf( swiz ), 1 );
		}
		
		public static function setUp( dObj:DisplayObject ):void
		{
			var uid:String = UIDUtil.getUID( dObj );
			
			// already wired
			if( wiredViews.indexOf( uid ) > -1 )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				if( DisplayObjectContainer( swiz.dispatcher ).contains( dObj ) )
				{
					wiredViews.push( uid );
					swiz.beanFactory.setUpBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
					return;
				}
			}
		}
		
		public static function tearDown( dObj:DisplayObject ):void
		{
			var uid:String = UIDUtil.getUID( dObj );
			
			// wasn't wired
			if( wiredViews.indexOf( uid ) == -1 )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				if( DisplayObjectContainer( swiz.dispatcher ).contains( dObj ) )
				{
					wiredViews.splice( wiredViews.indexOf( uid ), 1 );
					swiz.beanFactory.tearDownBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
					return;
				}
			}
		}
	}
}