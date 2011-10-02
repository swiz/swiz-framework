package org.swizframework.mediation
{
	public class ComplexTypeMatcher implements ITypeMatcher
	{
		public var requiredTypes:Array;
		public var optionalTypes:Array;
		public var prohibitedTypes:Array;
		
		public function ComplexTypeMatcher( requiredTypes:Array = null, optionalTypes:Array = null, prohibitedTypes:Array = null ) 
		{
			this.requiredTypes = requiredTypes ? requiredTypes : [];
			this.optionalTypes = optionalTypes ? optionalTypes : [];
			this.prohibitedTypes = prohibitedTypes ? prohibitedTypes : [];
		}
		
		
		public function and( type:Class ):ComplexTypeMatcher
		{
			requiredTypes.push( type );
			return this;
		}
		
		public function butNot( type:Class ):ComplexTypeMatcher
		{
			prohibitedTypes.push( type );
			return this;
		}
		
		public function andNot( type:Class ):ComplexTypeMatcher
		{
			prohibitedTypes.push( type );
			return this;
		}
		
		public var mediatorType:Class;
		
		public function to( type:Class ):IMediatorMapping
		{
			return new MediatorMapping( this, type );
		}
		
		public function matches( object:* ):Boolean
		{
			var type:Class;
			
			if( prohibitedTypes )
			{
				for each( type in prohibitedTypes )
				{
					if( object is type )
						return false;
				}
			}
			
			if( requiredTypes )
			{
				for each( type in requiredTypes )
				{
					if( !( object is type ) )
						return false;
				}
				
				return true;
			}
			
			if( optionalTypes )
			{
				for each( type in optionalTypes )
				{
					if( object is type )
						return true;
				}
			}
			
			return false;
		}
	}
}