package org.swizframework.processors
{
	import org.swizframework.reflection.IMetadataTag;

	public interface IMetadataProcessor extends IProcessor
	{
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Metadata Name
		 */
		function get metadataName():String;
		
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
		function addMetadata( bean:Object, metadata:IMetadataTag ):void;
		
		/**
		 * Remove Metadata
		 */
		function removeMetadata( bean:Object, metadata:IMetadataTag ):void;
		
	}
}