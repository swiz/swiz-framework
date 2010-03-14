package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.core.OutjectBean;
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
		public function OutjectProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ OUTJECT ] : metadataNames );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var outjectBean:OutjectBean = new OutjectBean();
			
			// store ref to bean containing [Outject] definition
			outjectBean.parentBean = bean;
			// store name of property decorated with [Outject]
			outjectBean.outjectedPropName = metadataTag.host.name;
			// outjecting a bean by type should be extremely rare, but we gotta check
			if( metadataTag.args.length > 0 )
				outjectBean.name = metadataTag.args[ 0 ][ "value" ];
			// store ref to the actual outjected value
			outjectBean.source = bean.source[ metadataTag.host.name ];
			// gotta have a descriptor
			outjectBean.typeDescriptor = TypeCache.getTypeDescriptor( metadataTag.host.type );
			
			// add new bean to the factory
			beanFactory.beans.push( outjectBean );
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