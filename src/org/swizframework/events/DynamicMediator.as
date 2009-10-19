package org.swizframework.events {
	import flash.events.Event;
	
	public class DynamicMediator {
		private var handler : Function;
		private var properties : Array;
		
		public var eventType : String;
		
		public var stopPropagation : Boolean = false;
		public var stopImmediatePropagation : Boolean = false;
		
		public function DynamicMediator( handler : Function, props : String, eventType : String ) {
			this.handler = handler;
			if ( props != null )
				this.properties = props.split( "," );
			this.eventType = eventType;
		}
		
		// changed type from Event to * to allow typed event parameter
		// when no properties are set and method expects event as argument
		public function respond( event : * ) : void {
			
			// build the argument array for the handler function, if all the properties are not found, throw an error
			var args : Array;
			if ( properties != null ) {
				args = new Array();
				for ( var i : int = 0; i < properties.length; i++ ) {
					// maybe do a try catch for the reference error?
					try {
						args.push( event[ properties[i] ] );
					} catch ( e : ReferenceError ) {
						throw new Error( "DynamicMediator.responseError: Property '" + properties[ i ] + "' does not exist in event type '" + event.type );
					}
				}
			}
			
			
			if ( properties == null ) {
				// we assume the callback function has no arguments
				try {
					handler.apply( null );
				}
				// if there are arguments expected we assume it to be
				// the event itself
				catch ( e : Error ) {
					handler.apply( null, [ event ] );
				}
			} else {
				// now call the target method with the arg array
				handler.apply( null, args );
			}
			
			
			if ( stopPropagation )
				event.stopPropagation();
			
			if ( stopImmediatePropagation )
				event.stopImmediatePropagation();
		}
	}
}