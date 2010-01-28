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
		 * Name of metadata tags in which this processor is interested.
		 */
		function get metadataNames():Array;

		// ========================================
		// public methods
		// ========================================

		/**
		 * Process the metadata tags for the provided <code>Bean</code>
		 * so they are ready to use.
		 *
		 * @param metadataTags Array of tags culled from this <code>Bean</code>'s <code>TypeDescriptor</code>
		 * @param bean		   <code>Bean</code> instance to process
		 */
		function setUpMetadataTags( metadataTags:Array, bean:Bean ):void;

		/**
		 * Process the metadata tags for the provided <code>Bean</code>
		 * so they are ready to be cleaned up.
		 *
		 * @param metadataTags Array of tags culled from this <code>Bean</code>'s <code>TypeDescriptor</code>
		 * @param bean		   <code>Bean</code> instance to process
		 */
		function tearDownMetadataTags( metadataTags:Array, bean:Bean ):void;
	}
}