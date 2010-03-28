package org.swizframework.reflection
{
	/**
	 * Representation of a method that has been decorated with metadata.
	 */
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
		protected var _parameters:Array = [];
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @return Reference to type returned by this method. Will be null if return type is <code>void</code> or <code>* </code>.
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
		 * @return Array of <code>MethodParameter</code> instances representing this method's parameters.
		 */
		public function get parameters():Array
		{
			return _parameters;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor sets <code>returnType</code> property based on value found in <code>hostNode</code> XML node,
		 * as long as return type is not <code>void</code> or <code>* </code>. Also populates <code>parameters</code>
		 * property from information found in <code>hostNode</code> XML node.
		 *
		 * @param hostNode XML node from <code>describeType</code> output that represents this method.
		 */
		public function MetadataHostMethod()
		{
			super();
		}
	}
}