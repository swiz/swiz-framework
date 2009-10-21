package org.swizframework.ioc
{
	public class BeanLoader implements IBeansProvider
	{
		// ========================================
		// beans property (read-only)
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter.
		 */
		protected var _beans:Array;
		
		/**
		 * 
		 */
		public function get beans():Array
		{
			return _beans;
		}
	}
}