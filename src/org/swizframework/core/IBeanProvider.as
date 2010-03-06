package org.swizframework.core
{
	import flash.events.IEventDispatcher;
	
	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider
	{
		function get beans():Array;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
	}
}
