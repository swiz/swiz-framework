package org.swizframework.reflection
{
	public class MetadataHostMethod extends BaseMetadataHost
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>returnType</code> getter/setter.
		 */
		protected var _returnType:Class;
		
		/**
		 * Backing variable for <code>parameters</code> getter/setter.
		 */
		protected var _parameters:Array;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public function get returnType():Class
		{
			return _returnType;
		}
		
		public function set returnType( value:Class ):void
		{
			_returnType = value;
		}
		
		[ArrayElementType( "org.swizframework.reflection.MethodParameter" )]
		
		/**
		 * 
		 */
		public function get parameters():Array
		{
			return _parameters;
		}
		
		public function set parameters( value:Array ):void
		{
			_parameters = value;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataHostMethod()
		{
			super();
		}
	}
}