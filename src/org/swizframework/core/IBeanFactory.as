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
		function initializeBean( bean:Bean ):void;
		
		/**
		 * Maybe better to extend bean provider interface
		 */
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
	}
}