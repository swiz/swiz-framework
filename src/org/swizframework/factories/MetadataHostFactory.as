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

package org.swizframework.factories
{
	import flash.system.ApplicationDomain;
	
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MetadataHostProperty;
	import org.swizframework.reflection.MethodParameter;
	
	/**
	 * Simple factory to create the different kinds of metadata
	 * hosts and to encapsulate the logic for determining which type
	 * should be created.
	 */
	public class MetadataHostFactory
	{
		public function MetadataHostFactory()
		{
			
		}
		
		/**
		 * Returns an <code>IMetadataHost</code> instance representing a property,
		 * method or class that is decorated with metadata.
		 *
		 * @param hostNode XML node representing a property, method or class
		 * @return <code>IMetadataHost</code> instance
		 *
		 * @see org.swizframework.reflection.MetadataHostClass
		 * @see org.swizframework.reflection.MetadataHostMethod
		 * @see org.swizframework.reflection.MetadataHostProperty
		 */
		public static function getMetadataHost( hostNode:XML, domain:ApplicationDomain ):IMetadataHost
		{
			var host:IMetadataHost;
			
			// property, method or class?
			var hostKind:String = hostNode.name();
			
			if( hostKind == "type" || hostKind == "factory" )
			{
				host = new MetadataHostClass();
				if( hostKind == "type" )
					host.type = domain.getDefinition( hostNode.@name.toString() ) as Class;
				else
					host.type = domain.getDefinition( hostNode.@type.toString() ) as Class;
			}
			else if( hostKind == "method" )
			{
				host = new MetadataHostMethod();
				
				if( hostNode.@returnType != "void" && hostNode.@returnType != "*" )
				{
					MetadataHostMethod( host ).returnType = Class( domain.getDefinition( hostNode.@returnType ) );
				}
				
				for each( var pNode:XML in hostNode.parameter )
				{
					var pType:Class = pNode.@type == "*" ? Object : Class( domain.getDefinition( pNode.@type ) );
					MetadataHostMethod( host ).parameters.push( new MethodParameter( int( pNode.@index ), pType, pNode.@optional == "true" ) );
				}
			}
			else
			{
				host = new MetadataHostProperty();
				host.type = hostNode.@type == "*" ? Object : Class( domain.getDefinition( hostNode.@type ) );
			}
			
			host.name = ( hostNode.@uri == undefined ) ? String( hostNode.@name[ 0 ] ) : new QName( hostNode.@uri, hostNode.@name );
			
			return host;
		}
	}
}