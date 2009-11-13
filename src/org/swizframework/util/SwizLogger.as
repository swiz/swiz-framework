package org.swizframework.util
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.ILoggingTarget;
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;
	
	public class SwizLogger extends EventDispatcher implements ILogger
	{
		protected static var loggers:Dictionary;
		protected static var logTargets:Array;
		
		public static function getLogger( target:Object ):ILogger
		{
			loggers ||= new Dictionary();
			
			var className:String = getQualifiedClassName( target );
			var logger:SwizLogger = loggers[ className ];
			
			// if the logger doesn't already exist, create and store it
			if( logger == null )
			{
				logger = new SwizLogger( className );
				loggers[ className ] = logger;
			}
			
			// check for existing targets interested in this logger
			if( logTargets != null )
			{
				for each( var logTarget:ILoggingTarget in logTargets )
				{
					if( SwizLogger.categoryMatchInFilterList( logger.category, logTarget.filters ) )
						logTarget.addLogger( logger );
				}
			}
			
			return logger;
		}
		
		/**
		 *  This method checks that the specified category matches any of the filter
		 *  expressions provided in the <code>filters</code> Array.
		 *
		 *  @param category The category to match against
		 *  @param filters A list of Strings to check category against.
		 *  @return <code>true</code> if the specified category matches any of the
		 *            filter expressions found in the filters list, <code>false</code>
		 *            otherwise.
		 */
		public static function categoryMatchInFilterList(category:String, filters:Array):Boolean
		{
			var result:Boolean = false;
			var filter:String;
			var index:int = -1;
			for( var i:uint = 0; i < filters.length; i++ )
			{
				filter = filters[i];
				// first check to see if we need to do a partial match
				// do we have an asterisk?
				index = filter.indexOf("*");
				
				if( index == 0 )
					return true;
				
				index = index < 0 ? index = category.length : index -1;
				
				if( category.substring(0, index) == filter.substring(0, index) )
					return true;
			}
			return false;
		}
		
		public static function setLogTargets( logTargetsArr:Array ):void
		{
			logTargets = logTargetsArr;
			
			for each( var logTarget:ILoggingTarget in logTargets )
			{
				for each( var logger:ILogger in loggers )
				{
					if( categoryMatchInFilterList( logger.category, logTarget.filters ) )
						logTarget.addLogger( logger );
				}
			}
		}
		
		// ========================================
		// static stuff above
		// ========================================
		// ========================================
		// instance stuff below
		// ========================================
		
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
		
		protected function constructMessage( msg:String, params:Array ):String
		{
			// replace all of the parameters in the msg string
			for( var i:int = 0; i < params.length; i++ )
			{
				msg = msg.replace( new RegExp( "\\{" + i + "\\}", "g"), params[ i ] );
			}
			return msg;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 *  @inheritDoc
		 */
		public function log( level:int, msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), level ) );
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function debug( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), LogEventLevel.DEBUG ) );
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function info( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), LogEventLevel.INFO ) );
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function warn( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), LogEventLevel.WARN ) );
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function error( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), LogEventLevel.ERROR ) );
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function fatal( msg:String, ... rest ):void
		{
			if( hasEventListener( LogEvent.LOG ) )
			{
				dispatchEvent( new LogEvent( constructMessage( msg, rest ), LogEventLevel.FATAL ) );
			}
		}
	}
}
