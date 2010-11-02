/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.reflection
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import org.swizframework.core.SwizManager;
	import org.swizframework.factories.MetadataHostFactory;
	
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
		 * The Application Domain this TypeDescriptor is associated with
		 */
		public var domain:ApplicationDomain;
		
		/**
		 * Output of <code>flash.utils.describeType</code> for this type.
		 */
		public var description:XML;
		
		/**
		 * The Class of this type.
		 */
		public var type:Class;
		
		/**
		 * The fully qualified name of this type.
		 */
		public var className:String;
		
		/**
		 * The constants defined by this class.
		 */
		public var constants:Array = [];
		
		/**
		 * The fully qualified name of all superclasses this type extends.
		 */
		public var superClasses:Array = [];
		
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
				var metadataName:String = mdNode.@name;
				// flex 4 includes crazy metadata on every single property and method
				// in debug mode. the name starts with _, so we ignore that
				if( metadataName.indexOf( "_" ) == 0 || SwizManager.metadataNames.indexOf( metadataName ) < 0 )
					continue;
				
				// gather and store all key/value pairs for the metadata tag
				var args:Array = [];
				for each( var argNode:XML in mdNode.arg )
				{
					args.push( new MetadataArg( argNode.@key.toString(), argNode.@value.toString() ) );
				}
				
				var host:IMetadataHost = getMetadataHost( mdNode.parent() );
				
				var metadataTag:IMetadataTag = new BaseMetadataTag();
				metadataTag.name = metadataName;
				metadataTag.args = args;
				metadataTag.host = host;
				host.metadataTags.push( metadataTag );
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
			return metadataHosts[ metadataHostName ] = MetadataHostFactory.getMetadataHost( hostNode, domain );
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
		public function fromXML( describeTypeXml:XML, domain:ApplicationDomain ):TypeDescriptor
		{
			this.description = describeTypeXml;
			this.domain = domain;
			
			var classDescription:XML = null;
			
			if( description.factory == undefined )
			{
				classDescription = description;
				className = classDescription.@name;
			}
			else
			{
				classDescription = description.factory[ 0 ];
				className = classDescription.@type;
			}
			
			type = domain.getDefinition( className ) as Class;
			
			for each( var constNode:XML in description.constant )
				constants.push( new Constant( constNode.@name, type[ constNode.@name ] ) );
			
			for each( var extendsNode:XML in classDescription.extendsClass )
				superClasses.push( extendsNode.@type.toString() );
			
			for each( var interfaceNode:XML in classDescription.implementsInterface )
				interfaces.push( interfaceNode.@type.toString() );
			
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
					if( metadataTag.name.toLowerCase() == metadataTagName.toLowerCase() )
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
					if( metadataTag.name.toLowerCase() == metadataTagName.toLowerCase() )
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
					if( metadataTag.name.toLowerCase() == tagName.toLowerCase() )
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
		
		/**
		 * Returns true if this descriptor's className, superClass, or any interfaces
		 * match a typeName.
		 */
		public function satisfiesType( typeName:String ):Boolean
		{
			if( className == typeName )
				return true;
			
			for each( var superClass:String in superClasses )
				if( superClass == typeName )
					return true;
			
			for each( var interfaceName:String in interfaces )
				if( interfaceName == typeName )
					return true;
			
			return false;
		}
	}
}