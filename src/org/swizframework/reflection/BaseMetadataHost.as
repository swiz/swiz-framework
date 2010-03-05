package org.swizframework.reflection
{
	/**
	 * Base implementation of the IMetadataHost interface.
	 * Implements getters and setters and initializes <code>metadataTags</code> Array.
	 *
	 * @see org.swizframework.reflection.IMetadataHost
	 * @see org.swizframework.reflection.MetadataHostClass
	 * @see org.swizframework.reflection.MetadataHostMethod
	 * @see org.swizframework.reflection.MetadataHostProperty
	 */
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
		 * Backing variable for <code>metadataTags</code> getter/setter.
		 */
		protected var _metadataTags:Array;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @inheritDoc
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
		 * @inheritDoc
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
		 * @inheritDoc
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
		
		/**
		 * Constructor initializes <code>metadataTags</code> Array.
		 */
		public function BaseMetadataHost()
		{
			metadataTags = [];
		}
	}
}