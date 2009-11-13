package org.swizframework.processors
{
	import org.swizframework.metadata.Metadata;
	
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
		override public function addMetadata( bean:Object, metadata:Metadata ):void
		{
			bean[ metadata.targetName ] = Math.random() * 1000;
		}
		
		/**
		 * Remove Random
		 */
		override public function removeMetadata( bean:Object, metadata:Metadata ):void
		{
			bean[ metadata.targetName ] = 0;
		}
		
	}
}