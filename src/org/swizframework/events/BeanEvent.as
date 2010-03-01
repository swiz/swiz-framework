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
		
		/**
		 * The BeanEvent.ADDED constant defines the value of the type property
		 * of a beanAdded event object.
		 */
		public static const ADDED:String = "beanAdded";
		
		/**
		 * The BeanEvent.REMOVED constant defines the value of the type property
		 * of a beanRemoved event object.
		 */
		public static const REMOVED:String = "beanRemoved";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The <code>Bean</code> instance that was added or removed.
		 */
		public var bean:Bean;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanEvent( type:String, bean:Bean = null )
		{
			super( type, true, true );
			
			this.bean = bean;
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