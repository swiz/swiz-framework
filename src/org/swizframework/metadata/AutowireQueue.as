package org.swizframework.metadata
{
	import org.swizframework.core.Bean;
	
	/**
	 * Represents a queued request for autowiring.
	 */
	public class AutowireQueue
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The corresponding [Autowire] tag.
		 */
		public var autowireTag:AutowireMetadataTag;
		
		/**
		 * The object that contains the [Autowire] tag.
		 */
		public var bean:Bean;
		
		// ========================================
		// constructor
		// ========================================
		
		public function AutowireQueue( autowireTag:AutowireMetadataTag = null, bean:Bean = null )
		{
			super();
			
			this.autowireTag = autowireTag;
			this.bean = bean;
		}
	}
}