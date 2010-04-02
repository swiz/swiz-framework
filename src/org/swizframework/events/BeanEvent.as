package org.swizframework.events
{
	import flash.events.Event;
	
	import org.swizframework.core.Bean;
	
	/**
	 * Dispatched when a Bean is added to or removed from a
	 * <code>BeanProvider</code>.
	 *
	 * @see org.swizframework.core.BeanProvider
	 */
	public class BeanEvent extends Event
	{
		// ========================================
		// public static const
		// ========================================
		
		public static const SET_UP_BEAN:String = "setUpBean";
		
		public static const TEAR_DOWN_BEAN:String = "tearDownBean";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The <code>Bean</code> instance that was added or removed.
		 */
		public var bean:*;
		
		public var beanName:String;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanEvent( type:String, bean:* = null, beanName:String = null )
		{
			super( type, true, true );
			
			this.bean = bean;
			this.beanName = beanName;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @return Copy of this event
		 */
		override public function clone():Event
		{
			return new BeanEvent( type, bean );
		}
	}
}