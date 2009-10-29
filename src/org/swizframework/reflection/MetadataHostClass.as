package org.swizframework.reflection
{
	public class MetadataHostClass extends BaseMetadataHost
	{
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataHostClass()
		{
			super();
			
			_hostType = MetadataHostType.CLASS;
		}
	}
}