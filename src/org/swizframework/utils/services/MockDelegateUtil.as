package org.swizframework.utils.services
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.managers.CursorManager;
	
	public class MockDelegateUtil
	{
		public var token:AsyncToken;
		public var timer:Timer;
		public var mockData:Object;
		public var fault:Fault;
		
		/**
		 * If <code>true</code>, a busy cursor is displayed while the mock service is 
		 * executing. The default value is <code>false</code>.
		 */
		public var showBusyCursor:Boolean;
		
		public function MockDelegateUtil( showBusyCursor:Boolean = false )
		{
			this.showBusyCursor = showBusyCursor;
		}
		
		public function createMockResult( mockData:Object, delay:int = 10 ):AsyncToken
		{
			this.mockData = mockData;
			
			timer = new Timer( delay, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendMockResult );
			timer.start();
			
			if( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			return token = new AsyncToken();
		}
		
		protected function sendMockResult( event:TimerEvent ):void
		{
			if( showBusyCursor )
			{
				CursorManager.removeBusyCursor();
			}
			
			timer.removeEventListener( TimerEvent.TIMER, sendMockResult );
			timer = null;
			
			var re:ResultEvent = new ResultEvent( ResultEvent.RESULT, false, true, mockData );
			for each( var r:IResponder in token.responders )
			{
				r.result( re );
			}
		}
		
		public function createMockFault( fault:Fault = null, delay:int = 10 ):AsyncToken
		{
			this.fault = fault;
			
			timer = new Timer( delay, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendMockFault );
			timer.start();
			
			if( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			return token = new AsyncToken();
		}
		
		protected function sendMockFault( event:TimerEvent ):void
		{
			if( showBusyCursor )
			{
				CursorManager.removeBusyCursor();
			}
			
			timer.removeEventListener( TimerEvent.TIMER, sendMockFault );
			timer = null;
			
			var fe:FaultEvent = new FaultEvent( FaultEvent.FAULT, false, true, fault );
			for each( var r:IResponder in token.responders )
			{
				r.fault( fe );
			}
		}
	}
}