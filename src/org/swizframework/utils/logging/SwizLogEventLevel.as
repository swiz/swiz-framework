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
	public class SwizLogEventLevel
	{
		
		// ========================================
		// public static const. these are all the 
		// standard flex logging event levels
		// ========================================
		
		public static const FATAL:int = 1000;
		public static const ERROR:int = 8;
		public static const WARN:int = 6;
		public static const INFO:int = 4;
		public static const DEBUG:int = 2;
		public static const ALL:int = 0;
		
		public function SwizLogEventLevel()
		{
		}
	}
}