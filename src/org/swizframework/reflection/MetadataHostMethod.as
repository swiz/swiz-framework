package org.swizframework.reflection
{
	import flash.utils.getDefinitionByName;
	
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
		 * 
		 */
		public function get returnType():Class
		{
			return _returnType;
		}
		
		[ArrayElementType( "org.swizframework.reflection.MethodParameter" )]
		
		/**
		 * 
		 */
		public function get parameters():Array
		{
			return _parameters;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function MetadataHostMethod( hostNode:XML )
		{
			super();
			
			if( hostNode.@returnType != "void" && hostNode.@returnType != "*" )
				_returnType = Class( getDefinitionByName( hostNode.@returnType ) );
			
			for each( var pNode:XML in hostNode.parameter )
			{
				_parameters.push( new MethodParameter( int( pNode.@index ), Class( getDefinitionByName( pNode.@type ) ), pNode.@optional == "true" ) );
			}
		}
	}
}