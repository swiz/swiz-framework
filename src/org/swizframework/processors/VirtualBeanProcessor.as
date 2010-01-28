package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.processors.BaseMetadataProcessor;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;

	/**
	 * VirtualBean Processor
	 */
	public class VirtualBeanProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================

		protected static const VIRTUAL_BEAN:String = "VirtualBean";

		// ========================================
		// public properties
		// ========================================

		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.VIRTUAL_BEAN;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor
		 */
		public function VirtualBeanProcessor()
		{
			super( [ VIRTUAL_BEAN ] );
		}

		// ========================================
		// public methods
		// ========================================

		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var virtualBean:Bean = new Bean();
			if( metadataTag.args.length > 0 )
				virtualBean.name = metadataTag.args[ 0 ][ "value" ];
			virtualBean.source = bean.source[ metadataTag.host.name ];
			virtualBean.typeDescriptor = TypeCache.getTypeDescriptor( metadataTag.host.type );
			// TODO: does it matter which IBeanProvider this is added to?
			//should probably be same one as Bean
			IBeanProvider( swiz.beanProviders[ 0 ] ).addBean( virtualBean );
		}


		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			IBeanProvider( swiz.beanProviders[ 0 ] ).removeBean( bean.source[ metadataTag.host.name ] );
		}

	}
}