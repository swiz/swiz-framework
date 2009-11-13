package org.swizframework.di
{
	import org.swizframework.reflection.TypeDescriptor;
	
	[DefaultProperty( "source" )]
	
	public class Bean
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var source:*;
		
		/**
		 * 
		 */
		public var name:String;
		
		/**
		 * 
		 */
		public var typeDescriptor:TypeDescriptor;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean()
		{
		}
	}
}