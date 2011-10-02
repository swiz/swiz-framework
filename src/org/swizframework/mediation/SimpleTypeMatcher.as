package org.swizframework.mediation
{
	public class SimpleTypeMatcher implements ITypeMatcher
	{
		public var type:Class;
		
		public function SimpleTypeMatcher( type:Class = null )
		{
			this.type = type;
		}
		
		public function matches( object:* ):Boolean
		{
			return object is type;
		}
	}
}