package org.swizframework.metadata
{
	import org.swizframework.di.Bean;
	
	public class AutowireQueue
	{
		public var bean:Bean;
		public var autowire:AutowireMetadataTag;
		
		public function AutowireQueue( bean:Bean = null, autowire:AutowireMetadataTag = null )
		{
			super();
			
			this.bean = bean;
			this.autowire = autowire;
		}
		
	}
}