package org.swizframework.mediation
{
	public class MediatorMapping implements IMediatorMapping
	{
		public function MediatorMapping( matcher:ITypeMatcher, mediatorType:Class )
		{
			this.matcher = matcher;
			this.mediatorType = mediatorType;
		}
		
		protected var _matcher:ITypeMatcher;
		
		public function get matcher():ITypeMatcher
		{
			return _matcher;
		}
		
		public function set matcher( value:ITypeMatcher ):void
		{
			_matcher = value;
		}
		
		protected var _mediatorType:Class;
		
		public function get mediatorType():Class
		{
			return _mediatorType;
		}
		
		public function set mediatorType( value:Class ):void
		{
			_mediatorType = value;
		}
		
		public function matches( object:* ):Boolean
		{
			return matcher.matches( object );
		}
	}
}