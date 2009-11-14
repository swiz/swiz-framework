package org.swizframework.ioc
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.di.Bean;

	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider extends IEventDispatcher
	{
		
		function get beans():Array;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
		
		function getBeanByName( name:String ):Object;
		function getBeanByType( type:Class ):Object;
	}
}
