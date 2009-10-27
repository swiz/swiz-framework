package org.swizframework.reflect
{
	public class BaseMetadataHost implements IMetadataHost
	{
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
		
		public function BaseMetadataHost()
		{
			metadataTags = [];
		}
	}
}