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
	import flash.events.Event;

	public class SwizLogEvent extends Event
	{
		// ========================================
		// public static const
		// ========================================
		
		public static const LOG_EVENT:String = "log";
		
		// ========================================
		// public properties
		// ========================================
		
		public var message:String;
		public var level:int;
		
		public function SwizLogEvent( message:String, level:int )
		{
			super( LOG_EVENT, true, true );
			this.message = message;
			this.level = level;
		}
		
		// ========================================
		// clone method
		// ========================================

		override public function clone():Event
		{
			return new SwizLogEvent(message, level);
		}
	}
}