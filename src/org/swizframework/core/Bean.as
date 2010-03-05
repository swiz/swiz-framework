package org.swizframework.core
{
	import org.swizframework.reflection.TypeDescriptor;
	
	[DefaultProperty( "source" )]
	
	public class Bean
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var _source:*;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Source
		 */
		public function get source():*
		{
			return _source;
		}
		
		public function set source( value:* ):void
		{
			_source = value;
		}
		
		/**
		 * Name
		 */
		/**
		 * Backing variable for <code>name</code> getter/setter.
		 */
		protected var _name:String;
		
		/**
		 *
		 */
		public function get name():String
		{
			return ( _name == null ) ? source.toString() : _name;
		}
		
		public function set name( value:String ):void
		{
			_name = value;
		}
		
		/**
		 * Type Descriptor
		 */
		public var typeDescriptor:TypeDescriptor;
		
		/**
		 * Provider
		 */
		public var provider:IBeanProvider;
		
		/**
		 * BeanFactory
		 */
		public var beanFactory:IBeanFactory;
		
		/**
		 * Initialzed
		 */
		public var initialized:Boolean = false;
		
		public function get type():*
		{
			return source;
		}
		
		public var parent:Object;
		public var propName:String;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean( source:* = null, name:String = null, typeDescriptor:TypeDescriptor = null, provider:IBeanProvider = null )
		{
			this.source = source;
			this.name = name;
			this.typeDescriptor = typeDescriptor;
			this.provider = provider;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 *
		 */
		public function toString():String
		{
			return "Bean{ source: " + source + ", name: " + name + " }";
		}
	}
}