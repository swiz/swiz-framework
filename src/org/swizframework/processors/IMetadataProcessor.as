package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.IMetadataTag;

	public interface IMetadataProcessor extends IProcessor
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Metadata Name
		 */
		function get metadataNames():Array;
		
		/**
		 * Metadata Class
		 */
		function get metadataClass():Class;
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Add Metadata
		 */
		function addMetadata( metadataTag:IMetadataTag, bean:Bean ):void;
		
		/**
		 * Remove Metadata
		 */
		function removeMetadata( metadataTag:IMetadataTag, bean:Bean ):void;
	}
}