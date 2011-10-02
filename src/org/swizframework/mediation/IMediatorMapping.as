package org.swizframework.mediation
{
	public interface IMediatorMapping
	{
		function get matcher():ITypeMatcher;
		function set matcher( value:ITypeMatcher ):void;
		
		function get mediatorType():Class;
		function set mediatorType( value:Class ):void;
		
		function matches( object:* ):Boolean;
	}
}