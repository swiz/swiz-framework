package org.swizframework.util {
	import flash.events.EventDispatcher;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	/**
	 *
	 * @author soenkerohde
	 *
	 */
	public class TestResponder extends EventDispatcher implements IResponder {
		public function result( data : Object ) : void {
			dispatchEvent( data as ResultEvent );
		}
		
		public function fault( info : Object ) : void {
			dispatchEvent( info as FaultEvent );
		}
	}
}