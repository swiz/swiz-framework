package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * Dispatcher Processor
	 */
	public class DispatcherProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const DISPATCHER:String = "Dispatcher";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.DISPATCHER;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function DispatcherProcessor()
		{
			super( [ DISPATCHER ] );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			bean.source[ metadataTag.host.name ] = swiz.dispatcher;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			bean.source[ metadataTag.host.name ] = null;
		}
	}
}