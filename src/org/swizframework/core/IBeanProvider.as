package org.swizframework.core
{
	import flash.events.IEventDispatcher;
	
	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider extends IEventDispatcher
	{
		function get beans():Array;
		
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
		
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
	}
}
