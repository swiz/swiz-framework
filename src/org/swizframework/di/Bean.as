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
		public var name:String;
		
		/**
		 * 
		 */
		public var type:String;
		
		/**
		 * 
		 */
		public var superClassType:String;
		
		/**
		 * 
		 */
		public var interfaces:Array;
		
		/**
		 * 
		 */
		public var isView:Boolean = false;
		
		/**
		 * 
		 */
		public var typeDescription:XML;
		
		/**
		 * 
		 */
		public var autowireMembers:Array;
		
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