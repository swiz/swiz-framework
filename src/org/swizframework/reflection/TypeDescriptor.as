package org.swizframework.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.swizframework.factories.MetadataHostFactory;
	import org.swizframework.metadata.AutowireMetadataTag;
	import org.swizframework.metadata.MediateMetadataTag;
	
	/**
	 * Object representation of a given type, based on <code>flash.utils.describeType</code>
	 * output and primarily focused on metadata.
	 */
	public class TypeDescriptor
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Output of <code>flash.utils.describeType</code> for this type.
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
		 * Dictionary of <code>IMetadataHost</code> instances for this type, keyed by name.
		 * 
		 * @see org.swizframework.reflection.IMetadataHost
		 */
		public var metadataHosts:Dictionary;
		
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
		 * 
		 * @return <code>IMetadataHost</code> instances
		 */
		protected function getMetadataHosts( description:XML ):Dictionary
		{
			if( metadataHosts != null )
				return metadataHosts;
			
			metadataHosts = new Dictionary();
			
			// find all metadata tags in describeType()'s output XML
			// parent node will be the actual property/method/class node
			for each( var mdNode:XML in description..metadata )
			{
				// flex 4 includes crazy metadata on every single property and method
				// in debug mode. the name starts with _, so we ignore that
				if( String( mdNode.@name ).indexOf( "_" ) == 0 )
					continue;
				
				var host:IMetadataHost = getMetadataHost( mdNode.parent() );
				
				// gather and store all key/value pairs for the metadata tag
				var args:Array = [];
				for each( var argNode:XML in mdNode.arg )
				{
					args.push( new MetadataArg( argNode.@key.toString(), argNode.@value.toString() ) );
				}
				
				host.metadataTags.push( new BaseMetadataTag( mdNode.@name.toString(), args, host ) );
			}
			
			return metadataHosts;
		}
		
		/**
		 * Get <code>IMetadataHost</code> for provided XML node.
		 * 
		 * @param hostNode Node from <code>flash.utils.describeType</code> output
		 * @return <code>IMetadataHost</code> instance
		 */
		protected function getMetadataHost( hostNode:XML ):IMetadataHost
		{
			// name of property/method
			var metadataHostName:String = hostNode.@name.toString();
			
			// if it has already been created, return it and bail
			if( metadataHosts[ metadataHostName ] != null )
				return IMetadataHost( metadataHosts[ metadataHostName ] );
			
			// otherwise create, store and return it
			return metadataHosts[ metadataHostName ] = new MetadataHostFactory().getMetadataHost( hostNode );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Populates the <code>TypeDescriptor</code> instance from the data returned
		 * by <code>flash.utils.describeType</code>.
		 * 
		 * @see flash.utils.describeType
		 */
		public function fromXML( description:XML ):TypeDescriptor
		{
			this.description = description;
			className = description.@name;
			superClassName = description.@base;
			for each( var node:XML in description.implementsInterface )
				interfaces.push( node.@type.toString() );
			metadataHosts = getMetadataHosts( description );
			
			return this;
		}
		
		/**
		 * Determine whether or not this class has any instances of
		 * metadata tags with the provided name.
		 * 
		 * @param metadataTagName
		 * @return Flag indicating whether or not the metadata tag is present 
		 */
		public function hasMetadataTag( metadataTagName:String ):Boolean
		{
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				for each( var metadataTag:IMetadataTag in metadataHost.metadataTags )
				{
					if( metadataTag.name == metadataTagName )
						return true;
				}
			}
			return false;
		}
		
		/**
		 * Get all <code>IMetadataHost</code> instances for this type that are decorated
		 * with metadata tags with the provided name.
		 * 
		 * @param metadataTagName Name of tags to retrieve
		 * @return <code>IMetadataHost</code> instances
		 */
		public function getMetadataHostsWithTag( metadataTagName:String ):Array
		{
			var hosts:Array = [];
			
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				for each( var metadataTag:IMetadataTag in metadataHost.metadataTags )
				{
					if( metadataTag.name == metadataTagName )
					{
						hosts.push( metadataHost );
						continue;
					}
				}
			}
			
			return hosts;
		}
		
		/**
		 * Get all <code>IMetadataTag</code> instances for class member with the provided name.
		 * 
		 * @param tagName Name of metadata tags to find
		 * @return <code>IMetadataTag</code> instances
		 */
		public function getMetadataTagsByName( tagName:String ):Array
		{
			var tags:Array = [];
			
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				for each( var metadataTag:IMetadataTag in metadataHost.metadataTags )
				{
					if( metadataTag.name == tagName )
					{
						tags.push( metadataTag );
					}
				}
			}
			
			return tags;
		}
		
		/**
		 * Get all <code>IMetadataTag</code> instances for class member with the provided name.
		 * 
		 * @param memberName Name of class member (property or method)
		 * @return  <code>IMetadataTag</code> instances
		 */
		public function getMetadataTagsForMember( memberName:String ):Array
		{
			var tags:Array;
			
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				if( metadataHost.name == memberName )
				{
					tags = metadataHost.metadataTags;
				}
			}
			
			return tags;
		}
		
		/**
		 * Return all <code>MetadataHostProperty</code> instances for this type.
		 * 
		 * @return <code>MetadataHostProperty</code> instances
		 * 
		 * @see org.swizframework.reflection.MetadataHostProperty
		 */
		public function getMetadataHostProperties():Array
		{
			var hostProps:Array = [];
			
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				if( metadataHost is MetadataHostProperty )
				{
					hostProps.push( metadataHost );
					continue;
				}
			}
			
			return hostProps;
		}
		
		/**
		 * Return all <code>MetadataHostMethod</code> instances for this type.
		 * 
		 * @return <code>MetadataHostMethod</code> instances
		 * 
		 * @see org.swizframework.reflection.MetadataHostMethod
		 */
		public function getMetadataHostMethods():Array
		{
			var hostMethods:Array = [];
			
			for each( var metadataHost:IMetadataHost in metadataHosts )
			{
				if( metadataHost is MetadataHostMethod )
				{
					hostMethods.push( metadataHost );
					continue;
				}
			}
			
			return hostMethods;
		}
	}
}