package org.swizframework.events {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class CentralDispatcher extends EventDispatcher {
		/** Application Controller instance */
		private static var _centralDispatcher : CentralDispatcher;
		
		/** Core Swiz Events
		 public static const SWIZ_INITIALIZATION_COMPLETE : String = "eventSwizInitializationComplete"; */
		
		/** Lock to enforce singleton */
		private static var lock : Boolean = false;
		
		public function CentralDispatcher() {
			if ( !lock )
				throw new Error( "ApplicationController can only be defined once!" );
			initialize();
		}
		
		public static function getInstance() : CentralDispatcher {
			if ( _centralDispatcher == null ) {
				lock = true;
				_centralDispatcher = new CentralDispatcher();
				lock = false;
			}
			return _centralDispatcher;
		}
		
		private function initialize() : void {
			// todo: some initialization...
		}
		
		/**
		 * Basic dispatch function, dispatches simple named events
		 */
		public function dispatch( type : String ) : Boolean {
			return dispatchEvent( new Event( type ) );
		}
		
		/**
		 * Generic Fault Handler will be used by DynamicResponder if no resultHandler is supplied
		 */
		public function genericFault( info : Object ) : void {
			Alert.show( ObjectUtil.toString( info ) );
		}
	
	}
}