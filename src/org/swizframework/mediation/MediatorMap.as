package org.swizframework.mediation
{
	[DefaultProperty( "mappings" )]
	public class MediatorMap
	{
		public var mappings:Array = [];
		
		public function MediatorMap()
		{
			mapMediators();
		}
		
		protected function mapMediators():void
		{
			// empty for override
		}
		
		protected function map( mapping:IMediatorMapping ):void
		{
			mappings.push( mapping );
		}
		
		protected function match( type:Class ):ComplexTypeMatcher
		{
			return new ComplexTypeMatcher( [ type ] );
		}
	}
}