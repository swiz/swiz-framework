package org.swizframework.ioc
{
	public class BeanLoader implements IBeanProvider
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
		public function getBeans():Array
		{
			return _beans;
		}
	}
}