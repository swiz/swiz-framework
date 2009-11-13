package org.swizframework.metadata
{
	public class MediateQueue
	{
		
		public var metadata:MediateMetadata;
		public var method:Function;
		
		public function MediateQueue( metadata:MediateMetadata, method:Function )
		{
			this.metadata = metadata;
			this.method = method;
		}
		
	}
}