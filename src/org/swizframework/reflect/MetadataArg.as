package org.swizframework.reflect
{
	public class MetadataArg
	{
		// ========================================
		// public properties
		// ========================================
		
		public var key:String;
		public var value:String;
		
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataArg( key:String, value:String )
		{
			this.key = key;
			this.value = value;
		}
		
		// ========================================
		// public methods
		// ========================================
		
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