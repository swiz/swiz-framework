package org.swizframework.utils.services
{
	import mx.rpc.IResponder;
	
	[ExcludeClass]
	
	public class SwizResponder implements IResponder
	{
		private var resultHandler:Function;
		private var faultHandler:Function;
		private var resultHandlerArgs:Array;
		
		public function SwizResponder( resultHandler:Function, faultHandler:Function = null, resultHandlerArgs:Array = null )
		{
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.resultHandlerArgs = resultHandlerArgs;
		}
		
		public function result( data:Object ):void
		{
			if( resultHandlerArgs == null )
			{
				resultHandler( data );
			}
			else
			{
				resultHandlerArgs.unshift( data );
				resultHandler.apply( null, resultHandlerArgs );
			}
		}
		
		public function fault( info:Object ):void
		{
			if( faultHandler != null )
				faultHandler( info );
			// we could try / catch the call to the fault handler, if people wanted custom handlers
			// to recieve args in the same way as result handler
			else
			{
				// todo: what if there is no fault handler applied to dynamic responder
				// ben says fails silently, maybe logging is smarter...
			}
		}
	}
}