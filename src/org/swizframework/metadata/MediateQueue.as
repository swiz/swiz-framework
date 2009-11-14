package org.swizframework.metadata
{
	public class MediateQueue
	{
		public var metadata:MediateMetadataTag;
		public var method:Function;
		
		public function MediateQueue( metadata:MediateMetadataTag, method:Function )
		{
			this.metadata = metadata;
			this.method = method;
		}
	}
}