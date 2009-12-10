package org.swizframework.core
{
	/**
	 * Bean Factory Interface
	 */
	public interface IBeanFactory
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Injection Event
		 */
		function get injectionEvent():String;
		function set injectionEvent( value:String ):void;
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called by Swiz
		 */
		function init( swiz:ISwiz ):void;
	}
}