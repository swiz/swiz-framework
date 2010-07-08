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
	import flash.events.IEventDispatcher;
	
	public class EventChain extends BaseCompositeChain
	{
		/**
		 * Backing variable for <code>dispatcher</code> getter/setter.
		 */
		protected var _dispatcher:IEventDispatcher;
		
		/**
		 *
		 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher( value:IEventDispatcher ):void
		{
			_dispatcher = value;
		}
		
		public function EventChain( dispatcher:IEventDispatcher, mode:String = ChainType.SEQUENCE, stopOnError:Boolean = true )
		{
			super( mode, stopOnError );
			
			this.dispatcher = dispatcher;
		}
		
		public function addEvent( event:EventChainStep ):EventChain
		{
			addStep( event );
			return this;
		}
		
		/**
		 *
		 */
		override public function doProceed():void
		{
			if( currentStep is EventChainStep )
				dispatcher.dispatchEvent( Event( currentStep ) );
			else
				super.doProceed();
		}
	}
}
