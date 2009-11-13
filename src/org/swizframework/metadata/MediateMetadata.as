package org.swizframework.metadata
{
	import flash.utils.getDefinitionByName;
	
	import org.swizframework.util.MetadataUtil;

	public class MediateMetadata extends Metadata
	{
		
		public var event:String;
		public var properties:Array;
		public var priority:int;
		
		public function MediateMetadata( xml:XML )
		{
			super( xml );
			
			if ( xml != null )
			{
				event = MetadataUtil.getArg( xml, "event" );
				properties = MetadataUtil.hasArg( xml, "properties" ) ? MetadataUtil.getArg( xml, "properties" ).split( /\s*,\s*/ ) : null;
				priority = int( MetadataUtil.getArg( xml, "priority" ) );
				
				if ( event.indexOf( "." ) != -1 )
				{
					var eventParts:Array = event.split( /\./, 1 );
					var eventClass:Object = flash.utils.getDefinitionByName( eventParts[0] );
					
					event = eventClass[ eventParts[1] ];
				}
			}
		}
		
	}
}