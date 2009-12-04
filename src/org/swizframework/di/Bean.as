package org.swizframework.di
{
	import org.swizframework.ioc.IBeanProvider;
	import org.swizframework.reflection.TypeDescriptor;
	
	[DefaultProperty( "source" )]
	
	public class Bean
	{
		
		// ========================================
		// private properties
		// ========================================
		
		private var _source:*;
		
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
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean( source:* = null, name:String = null, typeDescriptor:TypeDescriptor = null, provider:IBeanProvider = null )
		{
			super();
			
			this.source = source;
			this.name = name;
			this.typeDescriptor = typeDescriptor;
			this.provider = provider;
		}
	}
}