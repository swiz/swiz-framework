package org.swizframework.events
{
	import flash.events.Event;
	
	public class BeanEvent extends Event
	{
		
		// ========================================
		// public static const
		// ========================================
		
		public static const ADDED:String = "beanAdded";
		public static const REMOVED:String = "beanRemoved";
		
		// ========================================
		// public properties
		// ========================================
		
		public var bean:Object;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanEvent( type:String, bean:Object = null )
		{
			super( type, true, true );
			
			this.bean = bean;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		override public function clone():Event
		{
			return new BeanEvent( type, bean );
		}
		
	}
}