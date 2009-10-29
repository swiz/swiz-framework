package org.swizframework.di
{
	import org.swizframework.reflection.TypeDescriptor;
	
	public class Bean
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var instance:*;
		
		/**
		 * 
		 */
		public var name:String;
		
		/**
		 * 
		 */
		public var isView:Boolean = false;
		
		/**
		 * 
		 */
		public var typeDescriptor:TypeDescriptor;
		
		/**
		 * 
		 */
		public var autowiredStatus:int;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean()
		{
		}
	}
}