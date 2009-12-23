package org.swizframework.util.rpc
{
	import mx.rpc.IResponder;
	
	public class DynamicResponder implements IResponder {
		
		private var resultHandler : Function;
		private var faultHandler : Function;
		private var args : Array;
		
		public function DynamicResponder( resultHandler : Function,
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
			else {
				// todo: what if there is no fault handler applied to dynamic responder
			}
		}
	
	}
}