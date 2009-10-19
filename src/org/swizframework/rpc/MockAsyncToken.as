package org.swizframework.rpc {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.PropertyChangeEvent;
	import mx.messaging.messages.AbstractMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	public class MockAsyncToken extends AsyncToken {
		private var mockResult:Object;
		
		// Hijack _responders for mock purposes.
		private var _responders:Array = [];
		
		// Hijack result for mock purposes.
		private var _result:Object;
		
		public function MockAsyncToken( mockResult : Object, delay : Number = 1000 ) {
			
			super( new AbstractMessage() );
			
			// Store result
			this.mockResult = mockResult;
			
			// Set up timer			
			var timer:Timer = new Timer( delay, 1 );
			
			// Note no weak ref: we keep a ref to the timer in place with the handler until it fires once.
			timer.addEventListener( TimerEvent.TIMER, this.timerIntervalHandler );
			
			timer.start();
		}
		
		override public function get responders() : Array {
			return _responders;
		}
		
		override public function addResponder( responder : IResponder ) : void {
			_responders.push( responder );
		}
		
		[Bindable( event="propertyChange" )]
		override public function get result() : Object {
			return _result;
		}
		
		private function setResult( newResult : Object ) : void {
			if ( _result !== newResult ) {
				var event:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent( this, "result", _result, newResult );
				_result = newResult;
				dispatchEvent( event );
			}
		}
		
		public function applyResult( event : ResultEvent ) : void {
			setResult( this.mockResult );
			
			if ( _responders != null ) {
				for ( var i : uint = 0; i < _responders.length; i++ ) {
					var responder:IResponder = _responders[i];
					if ( responder != null ) {
						responder.result( event );
					}
				}
			}
		}
		
		private function timerIntervalHandler( event : TimerEvent ) : void {
			Timer( event.target ).removeEventListener( TimerEvent.TIMER, this.timerIntervalHandler );
			
			var resultEvent:MockResultEvent = MockResultEvent.createEvent( this.mockResult, this, this.message );
			
			this.dispatchEvent( resultEvent );
			
			resultEvent.callTokenResponders();
		}
	}
}