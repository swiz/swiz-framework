package org.swizframework.utils.services
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public interface IURLRequestHelper
	{
		function executeURLRequest( request:URLRequest, resultHandler:Function, faultHandler:Function = null,
									progressHandler:Function = null, httpStatusHandler:Function = null,
									handlerArgs:Array = null ):URLLoader
	}
}