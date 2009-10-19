package org.swizframework.rpc {
	import mx.messaging.messages.IMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class MockResultEvent extends ResultEvent {
		public function MockResultEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, result : Object = null, token : AsyncToken = null, message : IMessage = null ) {
			super( type, bubbles, cancelable, result, token, message );
		}
		
		public static function createEvent( result : Object = null, token : AsyncToken = null, message : IMessage = null ) : MockResultEvent {
			return new MockResultEvent( ResultEvent.RESULT, false, true, result, token, message );
		}
		
		/*
		 * Have the token apply the result.
		 */
		public function callTokenResponders() : void {
			if ( token != null )
				token.applyResult( this );
		}
	
	}
}