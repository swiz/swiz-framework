package org.swizframework.utils.chain
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.IDispatcherAware;
	
	public class ChainUtil implements IDispatcherAware
	{
		private var _dispatcher:IEventDispatcher;
		
		public function ChainUtil()
		{
		}
		
		/** IDispatcherBean implementation */
		public function set dispatcher( dispatcher:IEventDispatcher ):void
		{
			_dispatcher = dispatcher;
		}
		
		/** Constructs a dynamic command */
		public function createCommand( delayedCall:Function, args:Array, resultHandler:Function,
			faultHandler:Function = null, resultHandlerArgs:Array = null ):AsyncChainStepCommand
		{
			return new AsyncChainStepCommand( delayedCall, args, resultHandler, faultHandler, resultHandlerArgs );
		}
		
		/** Constructs a dynamic command */
		public function createChain( mode:String = "sequence" ):CommandChain
		{
			return new CommandChain( true, mode );
		}
	}
}