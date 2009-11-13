package org.swizframework.metadata
{
	import org.swizframework.util.MetadataUtil;

	public class AutowireMetadata extends Metadata
	{
		
		public var bean:String;
		public var property:String;
		public var twoWay:Boolean = false;
		
		public function AutowireMetadata( xml:XML = null )
		{
			super( xml );
			
			if ( xml != null )
			{
				bean = MetadataUtil.getArg( xml, "bean" );
				property = MetadataUtil.getArg( xml, "property" );
				twoWay = MetadataUtil.getArg( xml, "twoWay" ) == "true";
			}
		}
		
	}
}