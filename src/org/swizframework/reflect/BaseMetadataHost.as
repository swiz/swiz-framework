package org.swizframework.reflect
{
	public class BaseMetadataHost implements IMetadataHost
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Backing variable for <code>hostType</code> getter/setter.
		 */
		protected var _hostType:String;
		
		/**
		 * 
		 */
		public function get hostType():String
		{
			return _hostType;
		}
		
		public function set hostType( value:String ):void
		{
			_hostType = value;
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
		
		//
		// isBindable getter
		//
		
		public function get isBindable():Boolean
		{
			for each( var tag:MetadataTag in metadataTags )
			{
				if( tag.name == "Bindable" )
					return true;
			}
			
			return false;
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
		
		/**
		 * 
		 */
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
	}
}