package org.swizframework.reflection
{
	public class MetadataHostProperty extends BaseMetadataHost
	{
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataHostProperty()
		{
			super();
			
			_hostType = MetadataHostType.PROPERTY;
		}
	}
}