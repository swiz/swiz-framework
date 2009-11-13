package org.swizframework.reflection
{
	public class BaseMetadataHost implements IMetadataHost
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>name</code> getter/setter.
		 */
		protected var _name:String;
		
		/**
		 * Backing variable for <code>type</code> getter/setter.
		 */
		protected var _type:Class;
		
		/**
		 * Backing variable for <code>metadata</code> getter/setter.
		 */
		protected var _metadataTags:Array;
		
		// ========================================
		// public properties
		// ========================================
		
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
		
		/**
		 * 
		 */
		public function get type():Class
		{
			return _type;
		}
		
		public function set type( value:Class ):void
		{
			_type = value;
		}
		
		[ArrayElementType( "org.swizframework.reflection.IMetadataTag" )]
		
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
	}
}