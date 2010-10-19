/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	
	public class SwizManager
	{
		public static var swizzes:Array = [];
		public static var wiredViews:Dictionary = new Dictionary( true );
		public static var metadataNames:Array = [];
		
		public static function addSwiz( swiz:ISwiz ):void
		{
			swizzes.push( swiz );
			
			for each( var p:IProcessor in swiz.processors )
				if( p is IMetadataProcessor )
					metadataNames = metadataNames.concat( IMetadataProcessor( p ).metadataNames );
		}
		
		public static function removeSwiz( swiz:ISwiz ):void
		{
			swizzes.splice( swizzes.indexOf( swiz ), 1 );
		}
		
		public static function setUp( view:DisplayObject ):void
		{
			// already wired
			if( wiredViews[ view ] != null )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				if( DisplayObjectContainer( swiz.dispatcher ).contains( view ) )
				{
					setUpView( view, swiz );
					return;
				}
			}
			
			// pop ups not registered to a particular Swiz instance must be handled by the root instance
			setUpView( view, ISwiz( swizzes[ 0 ] ) );
		}
		
		private static function setUpView( viewToWire:DisplayObject, swizInstance:ISwiz ):void
		{
			wiredViews[ viewToWire ] = swizInstance;
			swizInstance.beanFactory.setUpBean( BeanFactory.constructBean( viewToWire, null, swizInstance.domain ) );
		}
		
		public static function tearDown( wiredView:DisplayObject ):void
		{
			// wasn't wired
			if( wiredViews[ wiredView ] == null )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				// if this is the dispatcher for a swiz instance tear down swiz 
				if( swiz.dispatcher == wiredView )
				{
					swiz.tearDown();
					return;
				}
			}
			
			// for tear down use the swiz instance that was associated at set up time 
			tearDownWiredView( wiredView, wiredViews[ wiredView ] );
		}
		
		public static function tearDownWiredView( wiredView:DisplayObject, swizInstance:ISwiz ):void
		{
			delete wiredViews[ wiredView ];
			swizInstance.beanFactory.tearDownBean( BeanFactory.constructBean( wiredView, null, swizInstance.domain ) );
		}
		
		public static function tearDownAllWiredViewsForSwizInstance( swizInstance:ISwiz ):void
		{
			for( var wiredView:* in wiredViews )
			{
				// this will also tear down the swiz dispatcher itself
				if( wiredViews[ wiredView ] == swizInstance )
				{
					tearDownWiredView( wiredView, swizInstance );
				}
			}
		}
	}
}