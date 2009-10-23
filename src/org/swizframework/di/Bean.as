package org.swizframework.di
{
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