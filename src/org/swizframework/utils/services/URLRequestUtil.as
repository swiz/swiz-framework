package org.swizframework.utils.services
{
	import flash.net.URLRequest;

	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;

	public class URLRequestUtil implements ISwizAware
	{
		private var _swiz:ISwiz;

		public function URLRequestUtil()
		{
		}

		public function set swiz( swiz :ISwiz ):void
		{
			_swiz = swiz;
		}

		public function get swiz():ISwiz
		{
			return _swiz;
		}

		/** Delegates execute url request call to Swiz */
		public function executeURLRequest( request:URLRequest, resultHandler:Function, faultHandler:Function = null,
			progressHandler:Function = null, httpStatusHandler:Function = null,
			eventArgs:Array = null ):void
		{

			// use default fault handler defined for swiz instance if not provided									  	
			if( faultHandler == null && swiz.config.defaultFaultHandler != null )
				faultHandler = swiz.config.defaultFaultHandler;

			var dynamicURLRequest:SwizURLRequest = new SwizURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, eventArgs );
		}
	}
}