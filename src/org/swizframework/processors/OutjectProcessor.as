package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;
	
	/**
	 * Outject Processor
	 */
	public class OutjectProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const OUTJECT:String = "Outject";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.OUTJECT;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function OutjectProcessor()
		{
			super( [ OUTJECT ] );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var outjectBean:Bean = new Bean();
			if( metadataTag.args.length > 0 )
				outjectBean.name = metadataTag.args[ 0 ][ "value" ];
			outjectBean.source = bean.source[ metadataTag.host.name ];
			outjectBean.typeDescriptor = TypeCache.getTypeDescriptor( metadataTag.host.type );
			// TODO: does it matter which IBeanProvider this is added to?
			//should probably be same one as Bean
			IBeanProvider( swiz.beanProviders[ 0 ] ).addBean( outjectBean );
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