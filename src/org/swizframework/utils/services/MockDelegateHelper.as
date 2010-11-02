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

package org.swizframework.utils.services
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class MockDelegateHelper
	{
		public var calls:Dictionary;
		public var fault:Fault;
		
		/**
		 * If <code>true</code>, a busy cursor is displayed while the mock service is
		 * executing. The default value is <code>false</code>.
		 */
		public var showBusyCursor:Boolean;
		
		public function MockDelegateHelper( showBusyCursor:Boolean = false )
		{
			this.showBusyCursor = showBusyCursor;
			calls = new Dictionary();
		}
		
		public function createMockResult( mockData:Object, delay:int = 10 ):AsyncToken
		{
			var token:AsyncToken = new AsyncToken();
			token.data = mockData;
			
			var timer:Timer = new Timer( delay, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendMockResult );
			timer.start();
			
			calls[ timer ] = token;
			
			if( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			return token;
		}
		
		protected function sendMockResult( event:TimerEvent ):void
		{
			if( showBusyCursor )
			{
				CursorManager.removeBusyCursor();
			}
			
			var timer:Timer = Timer( event.target );
			timer.removeEventListener( TimerEvent.TIMER, sendMockResult );
			
			if( calls[ timer ] is AsyncToken )
			{
				var token:AsyncToken = AsyncToken( calls[ timer ] );
				delete calls[ timer ];
				
				var mockData:Object = ( token.data ) ? token.data : new Object();
				token.mx_internal::applyResult(ResultEvent.createEvent(mockData, token));
			}
			
			timer = null;
		}
		
		public function createMockFault( fault:Fault = null, delay:int = 10 ):AsyncToken
		{
			var token:AsyncToken = new AsyncToken();
			token.data = fault;
			
			var timer:Timer = new Timer( delay, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendMockFault );
			timer.start();
			
			calls[ timer ] = token;
			
			if( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			return token;
		}
		
		protected function sendMockFault( event:TimerEvent ):void
		{
			if( showBusyCursor )
			{
				CursorManager.removeBusyCursor();
			}
			
			var timer:Timer = Timer( event.target );
			timer.removeEventListener( TimerEvent.TIMER, sendMockFault );
			
			if( calls[ timer ] is AsyncToken )
			{
				var token:AsyncToken = calls[ timer ];
				delete calls[ timer ];
				
				var fault:Fault = ( token.data ) ? token.data : null;
				token.mx_internal::applyFault( FaultEvent.createEvent( fault, token ) );
			}
			
			timer = null;
		}
	}
}