package org.swizframework.utils.services
{
	import mx.rpc.AsyncToken;
	
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	
	public class ServiceRequestUtil implements ISwizAware
	{
		private var _swiz:ISwiz;
		
		public function ServiceRequestUtil()
		{
		}
		
		public function set swiz( swiz:ISwiz ):void
		{
			_swiz = swiz;
		}
		
		public function get swiz():ISwiz
		{
			return _swiz;
		}
		
		/** Delegates execute service call to Swiz */
		public function executeServiceCall( call:AsyncToken, resultHandler:Function,
			faultHandler:Function = null, resultHandlerArgs:Array = null ):void
		{
			// use default fault handler defined for swiz instance if not provided									   	
			if( faultHandler == null && swiz.config.defaultFaultHandler != null )
				faultHandler = swiz.config.defaultFaultHandler;
			
			call.addResponder( new SwizResponder( resultHandler, faultHandler, resultHandlerArgs ) );
		}
	}
}