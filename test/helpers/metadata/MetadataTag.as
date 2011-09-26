package helpers.metadata
{
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	
	/**
	 * MetadataTag is a helper class used in unit tests.
	 * It implements the IMetadataTag interface, but doesn't implement any meaningful
	 * behavior.
	 *
	 * @author Jeff Roberts
	 */
	public class MetadataTag implements IMetadataTag
	{
		
		public function get name():String
		{
			return null;
		}
		
		public function set name(value:String):void
		{
		}
		
		public function get args():Array
		{
			return null;
		}
		
		public function set args(value:Array):void
		{
		}
		
		public function get host():IMetadataHost
		{
			return null;
		}
		
		public function set host(value:IMetadataHost):void
		{
		}
		
		public function get asTag():String
		{
			return null;
		}
		
		public function hasArg(argName:String):Boolean
		{
			return false;
		}
		
		public function getArg(argName:String):MetadataArg
		{
			return null;
		}
		
		public function copyFrom(metadataTag:IMetadataTag):void
		{
		}
		
		public function toString():String
		{
			return null;
		}
	}
}