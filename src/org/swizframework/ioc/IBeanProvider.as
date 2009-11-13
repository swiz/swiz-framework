package org.swizframework.ioc
{
	import flash.events.IEventDispatcher;

	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider extends IEventDispatcher
	{
		
		function get beans():Array;
		
		function addBean( bean:Object ):void;
		function removeBean( bean:Object ):void;
		
		function getBeanByName( name:String ):Object;
		function getBeanByType( type:Class ):Object;
	}
}
