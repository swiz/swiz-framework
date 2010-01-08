package org.swizframework.reflection
{
	/**
	 * Simple key/value representation of a metadata tag argument.
	 */	
	public class MetadataArg
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Name of metadata tag argument, e.g. "source" for [Autowire( source="someModel" )]
		 */		
		public var key:String;
		
		/**
		 * Value of metadata tag argument, e.g. "someModel" for [Autowire( source="someModel" )]
		 */		
		public var value:String;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor sets initial values of required parameters.
		 * 
		 * @param key
		 * @param value
		 */		
		public function MetadataArg( key:String, value:String )
		{
			this.key = key;
			this.value = value;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @return String representation of this metadata tag argument.
		 */		
		public function toString():String
		{
			var str:String = "MetadataArg: ";
			
			str += key + " = " + value + "\n";
			
			return str;
		}
	}
}