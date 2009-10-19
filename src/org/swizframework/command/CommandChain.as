package org.swizframework.command {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.swizframework.Swiz;
	import org.swizframework.rpc.DynamicCommand;
	
	public class CommandChain {
		public static const SERIES : int = 0;
		public static const PARALLEL : int = 1;
		
		// commands to execute
		private var commands : ArrayCollection;
		// current command
		private var index : int = -1;
		// execution mode
		private var mode : int;
		// complete
		private var complete : Boolean = false;
		
		// function to execute after chain completes
		public var completeHandler : Function;
		// event to fire after chain completes
		public var completeEvent : Event;
		// event type to create and distach after chain completes
		public var completeEventType : String;
		// function to execute if the chain fails
		public var faultHandler : Function;
		// event to fire if chain fails;
		public var faultEvent : Event;
		// event type to create and distach after chain fails
		public var faultEventType : String;
		
		public function CommandChain( mode : int = PARALLEL ) {
			this.commands = new ArrayCollection();
			this.mode = mode;
		}
		
		public function addCommand( command : DynamicCommand ) : CommandChain {
			commands.addItem( command );
			command.setCommandChain( this );
			return this;
		}
		
		public function proceed() : void {
			if ( mode == SERIES ) {
				// in series mode, we check for the next command to execute
				index++
				if ( index < commands.length ) {
					DynamicCommand( commands.getItemAt( index ) ).execute();
					complete = false;
				} else {
					complete = true;
				}
			} else {
				// in parallel, we need to fire ALL commands, and in each subsequent proceed call check for competion
				complete = true;
				for each ( var command : DynamicCommand in commands ) {
					if ( !command.complete ) {
						complete = false;
						if ( !command.executed )
							command.execute();
					}
				}
			}
			// if we have now completed the chain, we need to fire of appropriate events / functions
			if ( complete )
				completeChain();
		}
		
		public function fail() : void {
			failChain();
		}
		
		private function completeChain() : void {
			if ( completeEvent != null )
				Swiz.dispatchEvent( completeEvent );
			if ( completeEventType != null )
				Swiz.dispatch( completeEventType );
			if ( completeHandler != null )
				completeHandler();
		}
		
		private function failChain() : void {
			if ( faultEvent != null )
				Swiz.dispatchEvent( faultEvent );
			if ( faultEventType != null )
				Swiz.dispatch( faultEventType );
			if ( faultHandler != null )
				faultHandler();
		}
	}
}