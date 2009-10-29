package org.swizframework.reflection
{
	public class MetadataHostMethod extends BaseMetadataHost
	{
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataHostMethod()
		{
			super();
			
			_hostType = MetadataHostType.METHOD;
		}
	}
}