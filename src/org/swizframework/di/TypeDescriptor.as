package org.swizframework.di
{
	import org.swizframework.reflect.IMetadataHost;
	import org.swizframework.reflect.MetadataArg;
	import org.swizframework.reflect.MetadataHostClass;
	import org.swizframework.reflect.MetadataHostMethod;
	import org.swizframework.reflect.MetadataHostProperty;
	import org.swizframework.reflect.MetadataTag;
	
	/**
	 * This class is used to store basic information about types that Swiz
	 * needs to know about.
	 */
	public class TypeDescriptor
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Output of describeType() for this type.
		 */
		public var description:XML;
		
		/**
		 * The fully qualified name of this type.
		 */
		public var className:String;
		
		/**
		 * The fully qualified name of this type's super class.
		 */
		public var superClassName:String;
		
		/**
		 * The fully qualified name of all interfaces this type implements.
		 */
		public var interfaces:Array = [];
		
		/**
		 * Array of IMetadataHost instances for this type.
		 * 
		 * @see org.swizframework.reflect.IMetadataHost
		 */
		public var metadataHosts:Array = [];
		
		// ========================================
		// constructor
		// ========================================
		
		public function TypeDescriptor()
		{
			
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Gather and return all properties, methods or the class itself that 
		 * are decorated with metadata.
		 */
		protected function getMetadataHosts( description:XML ):Array
		{
			var host:IMetadataHost;
			
			// find all metadata tags in describeType()'s output XML
			// parent node will be the actual property/method/class node
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
				
				// gather and store all key/value pairs for the metadata tag
				var args:Array = [];
				for each( var argNode:XML in mdNode.arg )
				{
					args.push( new MetadataArg( argNode.@key.toString(), argNode.@value.toString() ) );
				}
				
				// create and store metadata tag as object
				var mt:MetadataTag = new MetadataTag( mdNode.@name.toString(), args, host );
				host.metadataTags.push( mt );
			}
			
			return metadataHosts;
		}
		
		/**
		 * Check to see if this type already has an IMetadataHost with the given name.
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
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Populates the TypeDescriptor instance from the data returned
		 * by flash.utils.describeType.
		 * 
		 * @see flash.utils.describeType
		 */
		public function fromXML( description:XML ):TypeDescriptor
		{
			description = description;
			className = description.@name;
			superClassName = description.@base;
			for each( var node:XML in description.implementsInterface )
				interfaces.push( node.@type.toString() );
			metadataHosts = getMetadataHosts( description );
			
			return this;
		}
	}
}