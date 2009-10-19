package org.swizframework.factory {
	import flash.events.IEventDispatcher;
	
	public interface IDispatcherBean {
		function set dispatcher( dispatcher : IEventDispatcher ) : void;
	}
}