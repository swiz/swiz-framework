package org.swizframework.utils.chain
{
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class AsyncChainStepCommand extends CommandChainStep implements IResponder
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 *
		 */
		protected var asyncMethod:Function;
		
		/**
		 *
		 */
		protected var asyncMethodArgs:Array;
		
		/**
		 *
		 */
		protected var resultHandler:Function;
		
		/**
		 *
		 */
		protected var faultHandler:Function;
		
		/**
		 *
		 */
		protected var resultHandlerArgs:Array;
		
		// ========================================
		// constructor
		// ========================================
		
		public function AsyncChainStepCommand( asyncMethod:Function, asyncMethodArgs:Array, 
											   resultHandler:Function, faultHandler:Function = null, 
											   resultHandlerArgs:Array = null )
		{
			this.asyncMethodArgs = asyncMethodArgs;
			this.asyncMethod = asyncMethod;
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
			this.resultHandlerArgs = resultHandlerArgs;
		}
		
		override public function execute():void
		{
			var token:AsyncToken;
			
			if( asyncMethodArgs != null )
				token = asyncMethod.apply( null, asyncMethodArgs );
			else
				token = asyncMethod();
			
			token.addResponder( this );
		}
		
		/**
		 *
		 */
		public function result( data:Object ):void
		{
			if( resultHandlerArgs == null )
			{
				resultHandler( data );
			}
			else
			{
				resultHandlerArgs.unshift( data );
				resultHandler.apply( this, resultHandlerArgs );
			}
			
			complete();
		}
		
		/**
		 *
		 */
		public function fault( info:Object ):void
		{
			if( faultHandler != null )
				faultHandler( info );
			
			error();
		}
	}
}