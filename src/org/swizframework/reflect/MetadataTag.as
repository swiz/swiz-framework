package org.swizframework.reflect
{
	public class MetadataTag
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var name:String;
		
		/**
		 * 
		 */
		public var args:Array;
		
		/**
		 * 
		 */
		public var host:IMetadataHost;
		
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataTag( name:String, args:Array = null, host:IMetadataHost = null )
		{
			this.name = name;
			this.args = ( args ) ? args : [];
			this.host = host;
		}
		
		/**
		 * 
		 */
		public function toString():String
		{
			var str:String = "MetadataTag: ";
			
			str += name + "\n";
			for each( var arg:MetadataArg in args )
			{
				str += "\t\t" + arg.toString() + "\n";
			}
			
			return str;
		}
	}
}