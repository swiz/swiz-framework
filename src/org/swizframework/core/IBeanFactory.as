package org.swizframework.core
{
	/**
	 * Bean Factory Interface
	 */
	public interface IBeanFactory
	{
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called by Swiz
		 */
		function init( swiz:ISwiz ):void;
	}
}