package org.swizframework.net {
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.swizframework.events.CentralDispatcher;
	
	/**
	 *
	 * DynamicUrlRequest can be used to wrap URLLoader calles.
	 * The faultHandler function will be used for IOErrors and SecurityErrors
	 * so you should type the argument Event and check/cast the specific type
	 * in the method body.
	 *
	 * When used implicitly from Swiz.executeUrlRequest or AbstractController.executeUrlRequest
	 * the generic fault handler will be applied if available. Otherwise in an error case
	 * the Swiz internal generic fault shows up.
	 *
	 */
	public class DynamicURLRequest {
		
		/**
		 *
		 * @param request
		 * @param resultHandler The resultHandler function must expect the an event. event.currentTarget.data should contain the result. Signature can be extended with additional eventArgs
		 * @param faultHandler The faultHandler function will be called for IOErrors and SecurityErrors with the specific error event.
		 * @param progressHandler
		 * @param httpStatusHandler
		 * @param eventArgs The eventArgs will be applied to the signature of the resultHandler function.
		 *
		 */
		public function DynamicURLRequest( request : URLRequest, resultHandler : Function, faultHandler : Function = null, progressHandler : Function = null, httpStatusHandler : Function = null, eventArgs : Array = null ) {
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener( Event.COMPLETE, function( e : Event ) : void
				{
					// we could apply the result directly but from the current knowledge applying the event itself
					// seems more flexible. This may change in the future if we don't see any necessarity for this.
					
					//var data:Object = e.currentTarget.data;
					if ( eventArgs == null ) {
						resultHandler( e );
					} else {
						eventArgs.unshift( e );
						resultHandler.apply( null, eventArgs );
					}
				} );
			
			loader.addEventListener( IOErrorEvent.IO_ERROR, function( e : IOErrorEvent ) : void
				{
					if ( faultHandler != null )
						faultHandler( e );
					else
						CentralDispatcher.getInstance().genericFault( e );
				} );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function( e : SecurityErrorEvent ) : void
				{
					if ( faultHandler != null )
						faultHandler( e );
					else
						CentralDispatcher.getInstance().genericFault( e );
				} );
			
			if ( progressHandler != null ) {
				loader.addEventListener( ProgressEvent.PROGRESS, function( e : ProgressEvent ) : void
					{
						progressHandler( e );
					} );
			}
			if ( httpStatusHandler != null ) {
				loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, function( e : HTTPStatusEvent ) : void
					{
						httpStatusHandler( e );
					} );
			}
			
			loader.load( request );
		}
	}
}