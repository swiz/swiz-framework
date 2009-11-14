package org.swizframework.processors
{
	import org.swizframework.di.Bean;
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
		override public function addMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			bean.source[ metadata.host.name ] = Math.random() * 1000;
		}
		
		/**
		 * Remove Random
		 */
		override public function removeMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			bean.source[ metadata.host.name ] = 0;
		}
		
	}
}