package org.swizframework.events
{
	import flash.events.Event;
	
	import org.swizframework.core.ISwiz;
	
	/**
	 * Dispatched when a Swiz instance is created or destroyed.
	 */
	public class SwizEvent extends Event
	{
		// ========================================
		// public static const
		// ========================================
		
		/**
		 * The BeanEvent.ADDED constant defines the value of the type property
		 * of a beanAdded event object.
		 */
		public static const CREATED:String = "swizCreated";
		
		/**
		 * The BeanEvent.REMOVED constant defines the value of the type property
		 * of a beanRemoved event object.
		 */
		public static const DESTROYED:String = "swizDestroyed";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The <code>ISwiz</code> instance that was created or destroyed.
		 */
		public var swiz:ISwiz;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function SwizEvent( type:String, swiz:ISwiz = null )
		{
			super( type, true, true );
			this.swiz = swiz;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @return Copy of this event
		 */
		override public function clone():Event
		{
			return new SwizEvent( type, swiz );
		}
	}
}