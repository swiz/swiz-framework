package org.swizframework.processors
{
	import flash.events.Event;
	
	import org.swizframework.metadata.MediateMetadata;
	import org.swizframework.metadata.MediateQueue;
	
	/**
	 * Mediate Processor
	 */
	public class MediateProcessor extends MetadataProcessor
	{
		
		// ========================================
		// public static constants
		// ========================================
		
		public static const MEDIATE:String = "Mediate";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var mediatorsByEventType:Object = {};
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function MediateProcessor()
		{
			super( MEDIATE, MediateMetadata, addMediator, removeMediator );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Mediator
		 */
		protected function addMediator( bean:Object, mediator:MediateMetadata ):void
		{
			mediatorsByEventType[ mediator.event ] = new MediateQueue( mediator, bean[ mediator.targetName ] );
			swiz.dispatcher.addEventListener( mediator.event, eventHandler, false, mediator.priority, true );
		}
		
		/**
		 * Remove Mediator
		 */
		protected function removeMediator( bean:Object, mediator:MediateMetadata ):void
		{
			swiz.dispatcher.removeEventListener( mediator.event, eventHandler, false );
			delete mediatorsByEventType[ mediator.event ];
		}
		
		/**
		 * Event Handler
		 */
		protected function eventHandler( event:Event ):void
		{
			var mediator:MediateQueue = MediateQueue( mediatorsByEventType[ event.type ] );

			if ( mediator.metadata.properties != null )
			{
				mediator.method.apply( null, getEventArgs( event, mediator.metadata.properties ) );
			}
			else if ( mediator.method.length == 1 )
			{
				mediator.method.apply( null, [ event ] );
			}
			else
			{
				mediator.method.apply();
			}
		}
		
		/**
		 * Get Event Arguments
		 */
		protected function getEventArgs( event:Event, properties:Array ):Array
		{
			var args:Array = [];
			
			for each ( var property:String in properties )
			{
				args[ args.length ] = event[ property ];
			}
			
			return args;
		}
		
	}
}