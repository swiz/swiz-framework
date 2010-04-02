package org.swizframework.core
{
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	public interface IBeanProvider
	{
		function get beans():Array;
		
		function addBean( bean:Bean ):void;
		function removeBean( bean:Bean ):void;
		function initialize( domain:ApplicationDomain ):void;
	}
}
