package org.swizframework.metadata
{
	import org.swizframework.core.Bean;
	
	/**
	 * Represents a deferred request for injection.
	 */
	public class Injection
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The corresponding [Inject] tag.
		 */
		public var injectTag:InjectMetadataTag;
		
		/**
		 * The object that contains the [Inject] tag.
		 */
		public var bean:Bean;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Injection( injectTag:InjectMetadataTag = null, bean:Bean = null )
		{
			super();
			
			this.injectTag = injectTag;
			this.bean = bean;
		}
	}
}