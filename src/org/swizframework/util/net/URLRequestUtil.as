package org.swizframework.util.net
{
	import flash.net.URLRequest;
	
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	import org.swizframework.util.event.ChainUtil;
	
	public class URLRequestUtil extends ChainUtil implements ISwizAware
	{
		private var _swiz : ISwiz;
		
		public function URLRequestUtil() { }
		
		public function set swiz( swiz :ISwiz ) : void
		{
			_swiz = swiz;
		}
		
		public function get swiz() : ISwiz
		{
			return _swiz;
		}
		
		/** Delegates execute url request call to Swiz */
		public function executeURLRequest( request : URLRequest, resultHandler : Function, faultHandler : Function = null,
												  progressHandler : Function = null, httpStatusHandler : Function = null,
												  eventArgs : Array = null ) : void {
			
			// use default fault handler defined for swiz instance if not provided									  	
			if ( faultHandler == null && swiz.defaultFaultHandler != null )
				faultHandler = swiz.defaultFaultHandler;
			
			var dynamicURLRequest:DynamicURLRequest = 
				new DynamicURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, eventArgs );
		}

	}
}