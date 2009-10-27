package org.swizframework.di
{
	import org.swizframework.reflect.IMetadataHost;
	import org.swizframework.reflect.MetadataArg;
	import org.swizframework.reflect.MetadataHostClass;
	import org.swizframework.reflect.MetadataHostMethod;
	import org.swizframework.reflect.MetadataHostProperty;
	import org.swizframework.reflect.MetadataTag;
	
	public class TypeDescriptor
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var description:XML;
		
		/**
		 * 
		 */
		public var className:String;
		
		/**
		 * 
		 */
		public var superClassName:String;
		
		/**
		 * 
		 */
		public var interfaces:Array = [];
		
		/**
		 * 
		 */
		public var metadataHosts:Array = [];
		
		// ========================================
		// constructor
		// ========================================
		
		public function TypeDescriptor()
		{
			
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function fromXML( description:XML ):TypeDescriptor
		{
			this.description = description;
			this.className = description.@name;
			trace( "TypeDescriptor created for", this.className );
			this.superClassName = description.@base;
			for each( var node:XML in description.implementsInterface )
				interfaces.push( node.@type.toString() );
			this.metadataHosts = getMetadataHosts( description );
			
			return this;
		}
		
		protected function getMetadataHosts( description:XML ):Array
		{
			var host:IMetadataHost;
			
			// find all Metadata tags in describeType()'s output XML
			// parent node will be the actual property/method node
			for each( var mdNode:XML in description..metadata )
			{
				// property, method or class?
				var metadataHostType:String = mdNode.parent().name();
				// name of property/method
				var metadataHostName:String = mdNode.parent().@name.toString();
				// if we don't already have an IMetadataHost object for this property/method
				if( !hasMetadataHostWithName( metadataHostName ) )
				{
					// actual type is determined by metadata's parent tag
					host = ( metadataHostType == "method" ) ? new MetadataHostMethod()
															: ( metadataHostType == "type" ) ? new MetadataHostClass()
																							 : new MetadataHostProperty();
					host.name = metadataHostName;
					metadataHosts.push( host );
				}
					
				var args:Array = [];
				for each( var argNode:XML in mdNode.arg )
				{
					args.push( new MetadataArg( argNode.@key.toString(), argNode.@value.toString() ) );
				}
				
				var mt:MetadataTag = new MetadataTag( mdNode.@name.toString(), args, host );
				host.metadataTags.push( mt );
			}
			
			return metadataHosts;
		}
		
		/**
		 * Check to see if this type already has an IMetadataHost with the given name.
		 * An IMetadataHost is a representation of a public property decorated with
		 * some kind of metadata so name collisions should be impossible.
		 * 
		 * @see org.swizframework.reflect.IMetadataHost
		 */
		protected function hasMetadataHostWithName( metadataHostName:String ):Boolean
		{
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				if( metadataHost.name == metadataHostName )
				{
					return true;
				}
			}
			
			return false;
		}
	}
}