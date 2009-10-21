package org.swizframework.di
{
	public class AutowireMember	
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
		public var args:Array;
		
		/**
		 * 
		 */
		public var isBindable:Boolean;
		
		/**
		 * 
		 */
		public var isWriteOnly:Boolean;
		
		// ========================================
		// constructor
		// ========================================
		
		public function AutowireMember( name:String, type:String, args:Array, isBindable:Boolean = false, isWriteOnly:Boolean = false )
		{
			this.name = name;
			this.type = type;
			this.args = args;
			this.isBindable = isBindable;
			this.isWriteOnly = isWriteOnly;
		}
	}
}