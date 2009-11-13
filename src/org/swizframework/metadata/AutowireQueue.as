package org.swizframework.metadata
{
	public class AutowireQueue
	{
		
		public var bean:Object;
		public var autowire:AutowireMetadata;
		
		public function AutowireQueue( bean:Object = null, autowire:AutowireMetadata = null )
		{
			super();
			
			this.bean = bean;
			this.autowire = autowire;
		}
		
	}
}