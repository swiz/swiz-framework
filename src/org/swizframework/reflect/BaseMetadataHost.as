package org.swizframework.reflect
{
	public class BaseMetadataHost implements IMetadataHost
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Backing variable for <code>type</code> getter/setter.
		 */
		protected var _type:String;
		
		/**
		 * 
		 */
		public function get type():String
		{
			return _type;
		}
		
		public function set type( value:String ):void
		{
			_type = value;
		}
		
		//
		// name property
		//
		
		/**
		 * Backing variable for <code>name</code> getter/setter.
		 */
		protected var _name:String;
		
		/**
		 * 
		 */
		public function get name():String
		{
			return _name;
		}
		
		public function set name( value:String ):void
		{
			_name = value;
		}
		
		//
		// metadata property
		//
		
		/**
		 * Backing variable for <code>metadata</code> getter/setter.
		 */
		protected var _metadataTags:Array;
		
		/**
		 * 
		 */
		public function get metadataTags():Array
		{
			return _metadataTags;
		}
		
		public function set metadataTags( value:Array ):void
		{
			_metadataTags = value;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function BaseMetadataHost()
		{
			metadataTags = [];
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/*
		 * 
		 *
		public function toString():String
		{
			var str:String = "IMetadataHost: ";
			
			str += name + "\n";
			for each( var tag:MetadataTag in metadataTags )
			{
				str += "\t" + tag.toString() + "\n";
			}
			
			return str;
		}
		*/
	}
}