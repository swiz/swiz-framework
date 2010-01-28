package org.swizframework.factories
{
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MetadataHostProperty;

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
		public function getMetadataHost( hostNode:XML ):IMetadataHost
		{
			var host:IMetadataHost;

			// property, method or class?
			var hostKind:String = hostNode.name();

			// actual type is determined by metadata's parent tag
			host = ( hostKind == "method" ) ? new MetadataHostMethod( hostNode )
											: ( hostKind == "type" ) ? new MetadataHostClass( hostNode )
																	 : new MetadataHostProperty( hostNode );

			host.name = hostNode.@name.toString();

			return host;
		}
	}
}