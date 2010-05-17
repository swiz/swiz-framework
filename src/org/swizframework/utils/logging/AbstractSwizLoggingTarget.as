/*
* Copyright 2010 Swiz Framework Contributors
* 
* Licensed under the Apache License, Version 2.0 (the "License"); you may not
* use this file except in compliance with the License. You may obtain a copy of
* the License. You may obtain a copy of the License at
* 
* http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations under
* the License.
*/

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