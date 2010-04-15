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

package org.swizframework.utils.chain
{
	import flash.events.Event;
	
	public class EventChainStep extends Event implements IChainStep
	{
		/**
		 * Backing variable for <code>chain</code> getter/setter.
		 */
		protected var _chain:IChain;
		
		/**
		 *
		 */
		public function get chain():IChain
		{
			return _chain;
		}
		
		public function set chain( value:IChain ):void
		{
			_chain = value;
		}
		
		protected var _isComplete:Boolean;
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		public function EventChainStep( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		/**
		 *
		 */
		public function complete():void
		{
			_isComplete = true;
			
			if( chain != null )
				chain.stepComplete();
		}
		
		/**
		 *
		 */
		public function error():void
		{
			if( chain != null )
				chain.stepError();
		}
		
		override public function clone():Event
		{
			return new EventChainStep( type, bubbles, cancelable );
		}
	}
}