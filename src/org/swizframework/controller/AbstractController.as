package org.swizframework.controller {
	import flash.net.URLRequest;
	
	import mx.rpc.AsyncToken;
	
	import org.swizframework.Swiz;
	import org.swizframework.rpc.DynamicCommand;
	
	public class AbstractController {
		
		public var swiz : Swiz;
		
		public function AbstractController() {
		}
		
		/** Delegates execute service call to Swiz */
		protected function executeServiceCall( call : AsyncToken, resultHandler : Function,
											   faultHandler : Function = null, eventArgs : Array = null ) : void {
			Swiz.executeServiceCall( call, resultHandler, faultHandler, eventArgs );
		}
		
		/** Delegates execute url request call to Swiz */
		protected function executeURLRequest( request : URLRequest, resultHandler : Function, faultHandler : Function = null,
											  progressHandler : Function = null, httpStatusHandler : Function = null,
											  eventArgs : Array = null ) : void {
			Swiz.executeURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, eventArgs );
		}
		
		/** Delegates create command to Swiz */
		protected function createCommand( delayedCall : Function, args : Array, resultHandler : Function,
										  faultHandler : Function = null, eventArgs : Array = null ) : DynamicCommand {
			return Swiz.createCommand( delayedCall, args, resultHandler, faultHandler, eventArgs );
		}
	
	}
}