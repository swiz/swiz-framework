package org.swizframework.reflection
{
	/**
	 * Representation of a method parameter.
	 */	
	public class MethodParameter
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Index of this parameter in method signature.
		 */
		public var index:int;
		
		/**
		 * Type of this parameter. Null if typed as <code>*</code>.
		 */		
		public var type:Class;
		
		/**
		 * Flag indicating whether or not this parameter is optional.
		 */
		public var optional:Boolean;
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor sets initial values of required parameters.
		 *  
		 * @param index
		 * @param type
		 * @param optional
		 */		
		public function MethodParameter( index:int, type:Class, optional:Boolean )
		{
			this.index = index;
			this.type = type;
			this.optional = optional;
		}
	}
}