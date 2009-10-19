package org.swizframework.util {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.managers.CursorManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.Fault;
	import flash.utils.setTimeout;
	import mx.rpc.events.FaultEvent;
	import flash.events.Event;
	
	/**
	 * @author soenkerohde, darron.schall
	 */
	public class TestUtil
	{
		/**
		 * addAsync can be used from TestCases which want to rest an
		 * asynchronous action (service call which returns AsyncToken)
		 *
		 * Usage from TestCase:
		 *
		 * function testLogin():void
		 * {
		 * 		TestUtil.addAsync( this, userDelegate.loginUser("foo", "bar"), onLogin, 5000 );
		 * }
		 *
		 * @param tc The TestCase itself from which this is called
		 * @param token The AsyncToken returned by the service-/delegate-call
		 * @param callback function to call in the testcase when operation is complete
		 * @param delay time to wait until the call is considered a failure
		 *
		 */
		public static function addAsync( testCase:Object, token:AsyncToken, callback:Function, delay:Number ):void
		{
			var responder:TestResponder = new TestResponder();
			token.addResponder( responder );
			// this has changed from addAsync, because I am now using fluint
			responder.addEventListener( ResultEvent.RESULT, testCase.asyncHandler( callback, delay ) );
		}
		
		/**
		 * mockResult can be used from mocked delegate
		 * a delegate method call generally returns an async token
		 * which is the result of a service call.
		 *
		 * Usage from mocked Delegate:
		 *
		 * function loginUser(username:String, password:String):AsyncToken
		 * {
		 * 		return TestUtil.mockResult(<user username="testUser" />, 1000);
		 * }
		 *
		 * @param result
		 * @param delay
		 * @param showBusyCursor
		 * @return
		 *
		 */
		public static function mockResult( result:*, delay:Number = 500, showBusyCursor:Boolean = true ):AsyncToken
		{
			return mockResultEvent( new ResultEvent( ResultEvent.RESULT, false, true, result ), delay, showBusyCursor );
		}
		
		/**
		 * @param resultEvent ResultEvent for IResponder
		 * @param delay in ms
		 * @param showBusyCursor to indicate pending with BusyCursor
		 * @return AsyncToken
		 *
		 */
		public static function mockResultEvent( event:ResultEvent, delay:Number = 500, showBusyCursor:Boolean = true ):AsyncToken
		{
			if ( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			// Create a new token that we can return so that responders can be attached to it
			var token:AsyncToken = new AsyncToken( null );
			
			// Wait until the delay expires, then notify the token responders
			// of the result to simulate asynchronous behavior.
			setTimeout( delayResultHelper, delay, token, event, showBusyCursor );
			
			return token;
		}
		
		/**
		 * mockFault can be used from mocked delegate to simulate a service
		 * call that results in an error condition.
		 * 
		 * Usage from mocked Delegate:
		 *
		 * function loginUser( username:String, password:String ):AsyncToken
		 * {
		 * 		if ( username == 'fail' )
		 * 		{
		 * 			return TestUtil.mockFault( new Fault( "100", "Invalid credentials" ), 1000);
		 * 		}
		 * 		else
		 * 		{
		 * 			return TestUtil.mockResult(<user username="testUser" />, 1000);
		 * 		}
		 * }
		 *
		 * @param fault
		 * @param delay The amount of time to delay before calling the responder, in milliseconds.
		 * @param showBusyCursor
		 * @return
		 *
		 */
		public static function mockFault( fault:Fault, delay:Number = 500, showBusyCursor:Boolean = true ):AsyncToken
		{
			return mockFaultEvent( new FaultEvent( FaultEvent.FAULT, false, true, fault ), delay, showBusyCursor );
		}
		
		/**
		 * @param faultEvent FaultEvent for IResponder
		 * @param delay The amount of time to delay before calling the responder, in milliseconds.
		 * @param showBusyCursor to indicate pending with BusyCursor
		 * @return AsyncToken
		 *
		 */
		public static function mockFaultEvent( event:FaultEvent, delay:Number = 500, showBusyCursor:Boolean = true ):AsyncToken
		{
			if ( showBusyCursor )
			{
				CursorManager.setBusyCursor();
			}
			
			// Create a new token that we can return so that responders can be attached to it
			var token:AsyncToken = new AsyncToken( null );
			
			// Wait until the delay expires, then notify the token responders
			// of the result to simulate asynchronous behavior.
			setTimeout( delayResultHelper, delay, token, event, showBusyCursor );
			
			return token;
		}
		
		/**
		 * Helper method that we can call after a delay to notify token responders
		 * of either a fault or result.
		 * 
		 * @param token The <code>AsyncToken</code> instance to call the responder on.
		 * @param event Either a <code>ResultEvent</code> or a <code>FaultEvent</code>.  The
		 * 		type of the event determines which responder to call on the token.
		 * @param showBusyCursor When <code>true</code>, the busy cursor is removed when
		 * 		this method executes.
		 */
		internal static function delayResultHelper( token:AsyncToken, event:Event, showBusyCursor:Boolean ):void
		{
			if ( showBusyCursor )
			{
				CursorManager.removeBusyCursor();
			}
			
			// Bail out if the token is not a valid reference
			if ( token == null )
			{
				return;
			}
			
			var responder:IResponder;
			
			// Determine the type of the event and call the appropriate responder
			if ( event is ResultEvent )
			{
				for each ( responder in token.responders )
				{
					responder.result( event );
				}
			}
			else if ( event is FaultEvent )
			{
				for each ( responder in token.responders )
				{
					responder.fault( event );
				}
			}
		}
		
	}
}