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
		protected function addMediator( mediateTag:MediateMetadataTag, bean:Bean ):void
		{
			mediatorsByEventType[ mediateTag.event ] = new MediateQueue( mediateTag, bean.source[ mediateTag.host.name ] );
			swiz.dispatcher.addEventListener( mediateTag.event, eventHandler, false, mediateTag.priority, true );
		}
		
		/**
		 * Remove Mediator
		 */
		protected function removeMediator( mediateTag:MediateMetadataTag, bean:Bean ):void
		{
			swiz.dispatcher.removeEventListener( mediateTag.event, eventHandler, false );
			delete mediatorsByEventType[ mediateTag.event ];
		}
		
		/**
		 * Event Handler
		 */
		protected function eventHandler( event:Event ):void
		{
			var mediator:MediateQueue = MediateQueue( mediatorsByEventType[ event.type ] );

			if ( mediator.metadataTag.properties != null )
			{
				mediator.method.apply( null, getEventArgs( event, mediator.metadataTag.properties ) );
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