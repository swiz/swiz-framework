package org.swizframework.core
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.Bean;

	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	public interface IBeanProvider extends IEventDispatcher
	{
		
		function get beans():Array;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
		
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
	}
}
