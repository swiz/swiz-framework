package org.swizframework.metadata
{
	/**
	 * Represents a queued request for mediation.
	 */
	public class MediateQueue
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The corresponding [Mediate] tag.
		 */
		public var metadataTag:MediateMetadataTag;
		
		/**
		 * The function decorated with the [Mediate] tag.
		 */
		public var method:Function;
		
		// ========================================
		// constructor
		// ========================================
		
		public function MediateQueue( metadata:MediateMetadataTag, method:Function )
		{
			this.metadataTag = metadata;
			this.method = method;
		}
	}
}