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
		function addMetadata( bean:Bean, metadata:IMetadataTag ):void;
		
		/**
		 * Remove Metadata
		 */
		function removeMetadata( bean:Bean, metadata:IMetadataTag ):void;
		
	}
}