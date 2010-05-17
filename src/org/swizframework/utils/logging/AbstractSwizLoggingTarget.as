package org.swizframework.utils.logging
{
	import org.swizframework.utils.logging.SwizLogger;

	public class AbstractSwizLoggingTarget
	{
		private var _filters:Array = [ "*" ];
		private var _level:int = SwizLogEventLevel.ALL;
		
		public function AbstractSwizLoggingTarget()
		{
		}
		
		public function get filters():Array
		{
			return _filters;
		}
		
		public function set filters( value:Array ):void
		{
			_filters = value;
		}
		
		public function get level():int
		{
			return _level;
		}
		
		public function set level( value:int ):void
		{
			// A change of level may impact the target level for Log.
			_level = value;      
		}
		
		public function addLogger( logger:SwizLogger ):void
		{
			if (logger)
			{
				logger.addEventListener(SwizLogEvent.LOG_EVENT, logHandler);
			}
		}

		public function removeLogger(logger:SwizLogger):void
		{
			if (logger)
			{
				logger.removeEventListener(SwizLogEvent.LOG_EVENT, logHandler);
			}
		}
		
		/** subclasses must override! */
		protected function logEvent( event:SwizLogEvent ):void
		{
			
		}
		
		protected function logHandler( event:SwizLogEvent ):void
		{
			if (event.level >= level)
				logEvent(event);
		}
	}
}