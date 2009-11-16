package org.swizframework.factories
{
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MetadataHostProperty;
	
	public class MetadataHostFactory
	{
		public function MetadataHostFactory()
		{
		}
		
		public function getMetadataHost( hostNode:XML ):IMetadataHost
		{
			var host:IMetadataHost;
			
			// property, method or class?
			var hostKind:String = hostNode.name();
			
			// actual type is determined by metadata's parent tag
			host = ( hostKind == "method" ) ? new MetadataHostMethod( hostNode )
											: ( hostKind == "type" ) ? new MetadataHostClass()
																	 : new MetadataHostProperty( hostNode );
			
			host.name = hostNode.@name.toString();
			
			return host;
		}
	}
}