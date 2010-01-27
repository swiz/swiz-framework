package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.metadata.PostConstructMetadataTag;
	import org.swizframework.processors.BaseMetadataProcessor;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;

	/**
	 * PostConstruct Processor
	 */
	public class PostConstructProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================

		protected static const POST_CONSTRUCT:String = "PostConstruct";

		// ========================================
		// public properties
		// ========================================

		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.POST_CONSTRUCT;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor
		 */
		public function PostConstructProcessor()
		{
			super( [ POST_CONSTRUCT ], PostConstructMetadataTag );
		}

		// ========================================
		// public methods
		// ========================================

		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			super.setUpMetadataTags( metadataTags, bean );

			metadataTags.sortOn( "order" );

			for each( var metadataTag:IMetadataTag in metadataTags )
			{
				var f:Function = bean.source[ metadataTag.host.name ];
				f.apply();
			}
		}
	}
}