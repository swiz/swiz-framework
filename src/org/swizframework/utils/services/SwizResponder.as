package org.swizframework.utils.services
{
	import mx.rpc.IResponder;
	
	public class SwizResponder implements IResponder {
		
		private var resultHandler : Function;
		private var faultHandler : Function;
		private var args : Array;
		
		public function SwizResponder( resultHandler : Function,
										  faultHandler : Function = null,
										  args : Array = null ) {
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.args = args;
		}
		
		public function result( data : Object ) : void {
			if ( args == null ) {
				resultHandler( data );
			} else {
				args.unshift( data );
				resultHandler.apply( null, args );
			}
		}
		
		public function fault( info : Object ) : void {
			if (faultHandler != null)
				faultHandler( info );
				// we could try / catch the call to the fault handler, if people wanted custom handlers
				// to recieve args in the same way as result handler
			else {
				// todo: what if there is no fault handler applied to dynamic responder
				// ben says fails silently, maybe logging is smarter...
			}
		}
	
	}
}