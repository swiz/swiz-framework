package org.swizframework.core
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
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
		public var name:String;
		
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
			// return Class( getDefinitionByName( getQualifiedClassName( source ) ) );
			return source;
		}
		
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