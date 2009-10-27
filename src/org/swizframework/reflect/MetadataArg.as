package org.swizframework.reflect
{
	public class MetadataArg
	{
		public var key:String;
		public var value:String;
		
		public function MetadataArg( key:String, value:String )
		{
			this.key = key;
			this.value = value;
		}
		
		/**
		 * 
		 */
		public function toString():String
		{
			var str:String = "MetadataArg: ";
			
			str += key + " = " + value + "\n";
			
			return str;
		}
	}
}