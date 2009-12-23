package org.swizframework.util.event
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.IDispatcherAware;
	
	public class ChainUtil implements IDispatcherAware
	{
		private var _dispatcher : IEventDispatcher;
		
		public function ChainUtil() { }
		
		/** IDispatcherBean implementation */
		public function set dispatcher( dispatcher : IEventDispatcher ) : void
		{
			_dispatcher = dispatcher;
		}
		
		/** Constructs a dynamic command */
		public function createCommand( delayedCall : Function, args : Array, resultHandler : Function,
										  faultHandler : Function = null, eventArgs : Array = null ) : DynamicCommand 
		{
			return new DynamicCommand( delayedCall, args, resultHandler, faultHandler, eventArgs );
		}
		
		/** Constructs a dynamic command */
		public function createChain( mode : int = CommandChain.PARALLEL ) : CommandChain 
		{
			return new CommandChain( _dispatcher, mode );
		}

	}
}