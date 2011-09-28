package helpers.metadata
{
	import org.osmf.metadata.Metadata;
	import org.swizframework.factories.MetadataHostFactory;
	import org.swizframework.reflection.BaseMetadataHost;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MetadataHostProperty;

	/**
	 * MetadataTagHelper is a test helper class that assists tests in the creation of metadata tag
	 * and hosts
	 */
	public class MetadataTagHelper
	{
		//------------------------------------------------------
		//
		// Class constants
		//
		//------------------------------------------------------
		
		public static const METADATA_HOST_TYPE_CLASS:String = "class";
		public static const METADATA_HOST_TYPE_METHOD:String = "method";
		public static const METADATA_HOST_TYPE_PROPERTY:String = "property";
		
		//------------------------------------------------------
		//
		// Public API
		//
		//------------------------------------------------------
		
		public function createBaseMetadataTagWithArgs(tagName:String, args:Object, metadataHostType:String, hostName:String = null, hostType:Class = null):BaseMetadataTag
		{
			var tag:BaseMetadataTag = new BaseMetadataTag();
			tag.name = tagName;
			tag.host = createMetadataHost(metadataHostType, hostName, hostType);
			tag.args = createMetadataArgs(args);
			
			return tag;
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous internal function(s)
		//
		//------------------------------------------------------
		
		private function createMetadataHost(metadataHostType:String, hostName:String, hostType:Class):IMetadataHost
		{
			var host:IMetadataHost;
			
			if ( metadataHostType == METADATA_HOST_TYPE_CLASS )
			{
				host = new MetadataHostClass();
			}
			else if ( metadataHostType == METADATA_HOST_TYPE_METHOD )
			{
				host = new MetadataHostMethod();
			}
			else if ( metadataHostType == METADATA_HOST_TYPE_PROPERTY )
			{
				host = new MetadataHostProperty();
			}
			else
			{
				host = new BaseMetadataHost();
			}
			
			host.name = hostName;
			host.type = hostType;
			
			return host;
		}
		
		private function createMetadataArgs(args:Object):Array
		{
			var metadataArgs:Array = [];
			
			for ( var name:String in args )
			{
				metadataArgs.push(new MetadataArg(name, String(args[name])));
			}
			
			return metadataArgs;
		}
	}
}