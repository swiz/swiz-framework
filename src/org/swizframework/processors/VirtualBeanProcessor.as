package org.swizframework.processors
{
	import org.swizframework.di.Bean;
	import org.swizframework.ioc.IBeanProvider;
	import org.swizframework.processors.MetadataProcessor;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;
	
	/**
	 * Random Processor
	 */
	public class VirtualBeanProcessor extends MetadataProcessor
	{
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function VirtualBeanProcessor()
		{
			super( "VirtualBean" );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Add Random
		 */
		override public function addMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			var virtualBean:Bean = new Bean();
			if( metadata.args.length > 0 )
				virtualBean.name = metadata.args[ 0 ][ "value" ];
			virtualBean.source = bean.source[ metadata.host.name ];
			virtualBean.typeDescriptor = TypeCache.getTypeDescriptor( metadata.host.type );
			
			IBeanProvider( swiz.beanProviders[ 0 ] ).addBean( virtualBean );
		}
		
		/**
		 * Remove Random
		 */
		override public function removeMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			IBeanProvider( swiz.beanProviders[ 0 ] ).removeBean( bean.source[ metadata.host.name ] );
		}
		
	}
}