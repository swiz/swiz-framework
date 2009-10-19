package org.swizframework.rpc {
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.swizframework.command.CommandChain;
	import org.swizframework.events.CentralDispatcher;
	
	public class DynamicCommand implements IResponder {
		private var delayedCall : Function;
		private var args : Array;
		private var resultHandler : Function;
		private var faultHandler : Function;
		private var eventArgs : Array;
		
		// command chain, if this command is chained
		private var chain : CommandChain;
		
		// complete / fault are read by a CommandChain object
		public var executed : Boolean = false;
		public var complete : Boolean = false;
		public var failed : Boolean = false;
		
		public function DynamicCommand( delayedCall : Function,
										args : Array,
										resultHandler : Function,
										faultHandler : Function = null,
										eventArgs : Array = null ) {
			this.delayedCall = delayedCall;
			this.args = args;
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.eventArgs = eventArgs;
		}
		
		public function execute() : void {
			executed = true;
			if ( delayedCall != null ) {
				var call : AsyncToken;
				if ( this.args != null )
					call = delayedCall.apply( null, this.args );
				else
					call = delayedCall();
				call.addResponder( this );
			}
		}
		
		public function result( data : Object ) : void {
			if ( eventArgs == null ) {
				resultHandler( data );
			} else {
				eventArgs.unshift( data );
				resultHandler.apply( null, eventArgs );
			}
			
			complete = true;
			if ( chain != null )
				chain.proceed();
		}
		
		public function fault( info : Object ) : void {
			failed = true;
			if ( faultHandler != null )
				faultHandler( info );
			else
				CentralDispatcher.getInstance().genericFault( info );
			if ( chain != null )
				chain.fail();
		}
		
		public function setCommandChain( chain : CommandChain ) : void {
			this.chain = chain;
		}
	
	}
}