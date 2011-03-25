package org.swizframework.processors
{
	import org.swizframework.core.IBeanFactory;

	public interface IFactoryProcessor extends IProcessor
	{
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Process the swin bean factory itself. Executes after all beans are loded but NOT yet set up.
		 *
		 * @param factory: the IBeanFactory instance to process
		 */
		function setUpFactory( factory:IBeanFactory ):void;
	}
}