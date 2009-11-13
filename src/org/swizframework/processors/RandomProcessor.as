package org.swizframework.processors
{
	import org.swizframework.metadata.Metadata;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * Random Processor
	 */
	public class RandomProcessor extends MetadataProcessor
	{
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function RandomProcessor()
		{
			super( "Random" );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Add Random
		 */
		override public function addMetadata( bean:Object, metadata:IMetadataTag ):void
		{
			bean[ metadata.host.name ] = Math.random() * 1000;
		}
		
		/**
		 * Remove Random
		 */
		override public function removeMetadata( bean:Object, metadata:IMetadataTag ):void
		{
			bean[ metadata.host.name ] = 0;
		}
		
	}
}