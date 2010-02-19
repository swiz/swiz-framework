package org.swizframework.core
{
	
	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider
	{
		function get beans():Array;
		
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
	}
}
