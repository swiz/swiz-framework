package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.metadata.PreDestroyMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * PreDestroy Processor
	 */
	public class PreDestroyProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const PRE_DESTROY:String = "PreDestroy";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.PRE_DESTROY;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function PreDestroyProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ PRE_DESTROY ] : metadataNames, PreDestroyMetadataTag );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			super.tearDownMetadataTags( metadataTags, bean );
			
			metadataTags.sortOn( "order" );
			
			for each( var metadataTag:IMetadataTag in metadataTags )
			{
				var f:Function = bean.source[ metadataTag.host.name ];
				f.apply();
			}
		}
	}
}