package org.swizframework.rpc {
	import mx.rpc.IResponder;
	
	import org.swizframework.events.CentralDispatcher;
	
	public class DynamicResponder implements IResponder
	{
		private var resultHandler : Function;
		private var faultHandler : Function;
		private var args : Array;
		
		public function DynamicResponder( resultHandler : Function,
										  faultHandler : Function = null,
										  args : Array = null )
		{
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.args = args;
		}
		
		public function result( data : Object ) : void
		{
			if ( args == null )
			{
				resultHandler( data );
			}
			else
			{
				args.unshift( data );
				resultHandler.apply( null, args );
			}
		}
		
		public function fault( info : Object ) : void
		{
			if ( faultHandler != null )
			{
				if ( args == null )
				{
					faultHandler( info );
				}
				else
				{
					args.unshift( info );
					faultHandler.apply( null, args );
				}
			}
			else
			{
				CentralDispatcher.getInstance().genericFault( info );
			}
		}
	
	}
}