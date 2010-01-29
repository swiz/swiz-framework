package org.swizframework.core
{
	import flash.events.IEventDispatcher;

	public interface IDispatcherAware
	{
		function set dispatcher( dispatcher:IEventDispatcher ):void;
	}
}