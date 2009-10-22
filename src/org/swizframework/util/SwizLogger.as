package org.swizframework.util
{
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;
	
	public class SwizLogger extends EventDispatcher implements ILogger
	{
		protected var _category:String;
		
		public function SwizLogger( target:Object )
		{
			super();
			
			_category = getQualifiedClassName( target );
		}
	
		/**
		 *  The category this logger send messages for.
		 */	
		public function get category():String
		{
			return _category;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		protected function buildMsg( msg:String, params:Array ):String
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < params.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), params[i]);
			}
			return msg;
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function log( level:int, msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), level ) );
			}
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function debug( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), LogEventLevel.DEBUG ) );
			}
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function error( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), LogEventLevel.ERROR ) );
			}
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function fatal( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), LogEventLevel.FATAL ) );
			}
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function info( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), LogEventLevel.INFO ) );
			}
		}
	
		/**
		 *  @inheritDoc
		 */	
		public function warn( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( buildMsg( msg, rest ), LogEventLevel.WARN ) );
			}
		}
	}
}