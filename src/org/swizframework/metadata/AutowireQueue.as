package org.swizframework.metadata
{
	public class AutowireQueue
	{
		
		public var bean:Object;
		public var autowire:AutowireMetadataTag;
		
		public function AutowireQueue( bean:Object = null, autowire:AutowireMetadataTag = null )
		{
			super();
			
			this.bean = bean;
			this.autowire = autowire;
		}
		
	}
}