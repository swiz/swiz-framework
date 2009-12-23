package org.swizframework.util.rpc
{
	import mx.rpc.AsyncToken;
	
	import org.swizframework.util.net.URLRequestUtil;
	
	public class RORequestUtil extends URLRequestUtil
	{
		public function RORequestUtil() { }
		
		/** Delegates execute service call to Swiz */
		public function executeServiceCall( call : AsyncToken, resultHandler : Function,
											   faultHandler : Function = null, eventArgs : Array = null ) : void {
											   	
			// use default fault handler defined for swiz instance if not provided									   	
			if ( faultHandler == null && swiz.defaultFaultHandler != null )
				faultHandler = swiz.defaultFaultHandler;
			
			call.addResponder( new DynamicResponder( resultHandler, faultHandler, eventArgs ) );
		}

	}
}