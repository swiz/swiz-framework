package org.swizframework.core
{
	import mx.logging.ILogger;
	
	import org.swizframework.utils.SwizLogger;

	/**
	 * @deprecated 
	 */
	public class BeanLoader extends BeanProvider
	{	
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:ILogger = SwizLogger.getLogger( this );
		
		// ========================================
		// Constructor
		// ========================================
		
		/**
		 * Constructor, logs as deprecated
		 */ 
		public function BeanLoader( beans:Array = null )
		{
			super( beans );
			logger.warn("BeanLoader is deprecated! Please refactor your loaders to BeanProvider as this class will be removed eventually!");
		}
	}
}
