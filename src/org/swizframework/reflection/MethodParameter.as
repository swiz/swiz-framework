package org.swizframework.reflection
{
	public class MethodParameter
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var index:int;
		
		/**
		 * 
		 */
		public var type:Class;
		
		/**
		 * 
		 */
		public var optional:Boolean;
		
		// ========================================
		// constructor
		// ========================================
		
		public function MethodParameter( index:int, type:Class, optional:Boolean )
		{
			this.index = index;
			this.type = type;
			this.optional = optional;
		}
	}
}