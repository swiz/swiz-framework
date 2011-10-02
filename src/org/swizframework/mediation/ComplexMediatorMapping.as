package org.swizframework.mediation
{
	public class ComplexMediatorMapping extends MediatorMapping
	{
		public var requiredTypes:Array;
		public var optionalTypes:Array;
		public var prohibitedTypes:Array;
		
		public function ComplexMediatorMapping( matcher:ITypeMatcher, mediatorType:Class )
		{
			this.matcher = matcher;
			this.mediatorType = mediatorType;
			
			super( matcher, mediatorType );
		}
		
		override public function matches( object:* ):Boolean
		{
			if( !matcher )
				matcher = new ComplexTypeMatcher( requiredTypes, optionalTypes, prohibitedTypes );
			
			return super.matches( object );
		}
	}
}