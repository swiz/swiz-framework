package org.swizframework.mediation
{
	public class TypeMatcher implements ITypeMatcher
	{
		public var typeToMatch:Class;
		public var strict:Boolean = false;
		
		public function TypeMatcher( typeToMatch:Class = null )
		{
			this.typeToMatch = typeToMatch;
		}
		
		public function matches( object:* ):Boolean
		{
			if( strict )
				return object.constructor == typeToMatch;
			else
				return object is typeToMatch;
		}
	}
}