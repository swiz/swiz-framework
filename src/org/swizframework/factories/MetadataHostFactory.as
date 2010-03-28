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
		private var domain:ApplicationDomain;
		
		public function MetadataHostFactory( domain:ApplicationDomain )
		{
			this.domain = domain;
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
		public function getMetadataHost( hostNode:XML ):IMetadataHost
		{
			var host:IMetadataHost;
			
			// property, method or class?
			var hostKind:String = hostNode.name();
			
			if( hostKind == "type" )
			{
				host = new MetadataHostClass();
				host.type = domain.getDefinition( hostNode.@name.toString() ) as Class;
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
			
			host.name = ( hostNode.@uri == undefined ) ? hostNode.@name : new QName( hostNode.@uri, hostNode.@name );
			
			return host;
		}
	}
}