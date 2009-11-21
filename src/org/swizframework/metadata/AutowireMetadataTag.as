package org.swizframework.metadata
{
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;

	public class AutowireMetadataTag extends BaseMetadataTag
	{
		// ========================================
		// public properties
		// ========================================
		
		public function get bean():String
		{
			if( hasArg( "bean" ) )
				return getArg( "bean" ).value;
			
			// bean is the default attribute
			// [Autowire( "appModel" )] == [Autowire( bean="appModel" )]
			// TODO: simplify/formalize default attribute specification?
			if( hasArg( "" ) )
				return getArg( "" ).value;
			
			return null;
		}
		
		public function get property():String
		{
			if( hasArg( "property" ) )
				return getArg( "property" ).value;
			
			return null;
		}
		
		public function get destination():String
		{
			if( hasArg( "destination" ) )
				return getArg( "destination" ).value;
			
			return null;
		}
		
		public function get twoWay():Boolean
		{
			return hasArg( "twoWay" ) && getArg( "twoWay" ).value == "true";
		}
		
		public function get view():Boolean
		{
			return hasArg( "view" ) && getArg( "view" ).value == "true";
		}
		
		public function get bind():Boolean
		{
			if( hasArg( "bind" ) )
				return getArg( "bind" ).value == "true";
			
			return true;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function AutowireMetadataTag( args:Array, host:IMetadataHost )
		{
			super( "Autowire", args, host );
		}
	}
}