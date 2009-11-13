package org.swizframework.metadata
{
	import org.swizframework.util.MetadataUtil;
	
	public class Metadata
	{
		
		public var targetName:String;
		public var targetType:Class;
		
		public function Metadata( xml:XML )
		{
			if ( xml != null )
			{
				targetName = MetadataUtil.getElementName( xml );
				targetType = MetadataUtil.getElementType( xml );
			}
		}
		
	}
}