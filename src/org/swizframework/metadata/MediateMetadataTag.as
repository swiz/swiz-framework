package org.swizframework.metadata
{
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;

	public class MediateMetadataTag extends BaseMetadataTag
	{
		// ========================================
		// public properties
		// ========================================
		
		public function get event():String
		{
			if( hasArg( "event" ) )
				return getArg( "event" ).value;
			
			return null;
		}
		
		public function get properties():Array
		{
			if( hasArg( "properties" ) )
			{
				var str:String = getArg( "properties" ).value.split( ", " ).join( "," );
				return str.split( "," );
			}
			
			return null;
		}
		
		public function get view():String
		{
			if( hasArg( "view" ) )
				return getArg( "view" ).value;
			
			return null;
		}
		
		public function get priority():int
		{
			if( hasArg( "priority" ) )
				return int( getArg( "priority" ).value );
			
			return -1;
		}
		
		public function get stopPropagation():Boolean
		{
			return hasArg( "stopPropagation" ) && getArg( "stopPropagation" ).value == "true";
		}
		
		public function get stopImmediatePropagation():Boolean
		{
			return hasArg( "stopImmediatePropagation" ) && getArg( "stopImmediatePropagation" ).value == "true";
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function MediateMetadataTag( args:Array, host:IMetadataHost )
		{
			super( "Mediate", args, host );
		}
	}
}