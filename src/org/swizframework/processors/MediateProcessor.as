package org.swizframework.processors
{
	import flash.events.Event;
	
	import org.swizframework.core.Bean;
	import org.swizframework.metadata.MediateMetadataTag;
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
			super( MEDIATE, MediateMetadataTag, addMediator, removeMediator );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Mediator
		 */
		protected function addMediator( bean:Bean, mediator:MediateMetadataTag ):void
		{
			mediatorsByEventType[ mediator.event ] = new MediateQueue( mediator, bean.source[ mediator.host.name ] );
			swiz.dispatcher.addEventListener( mediator.event, eventHandler, false, mediator.priority, true );
		}
		
		/**
		 * Remove Mediator
		 */
		protected function removeMediator( bean:Bean, mediator:MediateMetadataTag ):void
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