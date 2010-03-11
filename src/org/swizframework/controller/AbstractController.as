package org.swizframework.controller
{
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	
	import mx.rpc.AsyncToken;
	
	import org.swizframework.core.IDispatcherAware;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	import org.swizframework.utils.chain.CommandChain;
	import org.swizframework.utils.chain.SwizCommand;
	import org.swizframework.utils.services.SwizResponder;
	import org.swizframework.utils.services.SwizURLRequest;
	
	public class AbstractController implements ISwizAware, IDispatcherAware
	{
		public var _swiz:ISwiz;
		private var _dispatcher:IEventDispatcher;
		
		public function AbstractController()
		{
		}
		
		public function set swiz( swiz :ISwiz ):void
		{
			_swiz = swiz;
		}
		
		
		
		/** IDispatcherAware implementation */
		public function set dispatcher( dispatcher:IEventDispatcher ):void
		{
			_dispatcher = dispatcher;
		}
		
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		/** Delegates execute service call to Swiz */
		protected function executeServiceCall( call:AsyncToken, resultHandler:Function,
			faultHandler:Function = null, eventArgs:Array = null ):void
		{
			
			if( faultHandler == null && _swiz.config.defaultFaultHandler != null )
				faultHandler = _swiz.config.defaultFaultHandler;
			
			call.addResponder( new SwizResponder( resultHandler, faultHandler, eventArgs ) );
		}
		
		/** Delegates execute url request call to Swiz */
		protected function executeURLRequest( request:URLRequest, resultHandler:Function, faultHandler:Function = null,
			progressHandler:Function = null, httpStatusHandler:Function = null,
			eventArgs:Array = null ):void
		{
			
			if( faultHandler == null && _swiz.config.defaultFaultHandler != null )
				faultHandler = _swiz.config.defaultFaultHandler;
			
			var swizURLRequest:SwizURLRequest = 
				new SwizURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, eventArgs );
		}
		
		/** Delegates create command to Swiz */
		protected function createCommand( delayedCall:Function, args:Array, resultHandler:Function,
			faultHandler:Function = null, eventArgs:Array = null ):SwizCommand
		{
			return new SwizCommand( delayedCall, args, resultHandler, faultHandler, eventArgs );
		}
		
		/** Constructs a dynamic command */
		public function createChain( mode:String = "sequence" ):CommandChain
		{
			return new CommandChain( true, mode );
		}
	}
}