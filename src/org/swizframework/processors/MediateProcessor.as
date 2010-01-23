package org.swizframework.processors
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.core.Bean;
	import org.swizframework.metadata.MediateMetadataTag;
	import org.swizframework.metadata.MediateQueue;
	import org.swizframework.reflection.ClassConstant;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.reflection.TypeDescriptor;
	
	/**
	 * Mediate Processor
	 */
	public class MediateProcessor extends MetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const MEDIATE:String = "Mediate";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var mediatorsByEventType:Dictionary = new Dictionary();
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function MediateProcessor()
		{
			super( [ MEDIATE ], MediateMetadataTag, addMediator, removeMediator );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Mediator
		 */
		protected function addMediator( mediateTag:MediateMetadataTag, bean:Bean ):void
		{
			if ( validateMediateMetadataTag( mediateTag ) )
			{
				var eventType:String = parseEventTypeExpression( mediateTag.event );
				
				addMediatorByEventType( mediateTag, bean.source[ mediateTag.host.name ], eventType );
			}
		}
		
		/**
		 * Remove Mediator
		 */
		protected function removeMediator( mediateTag:MediateMetadataTag, bean:Bean ):void
		{
			var eventType:String = parseEventTypeExpression( mediateTag.event );
			
			removeMediatorByEventType( mediateTag, bean.source[ mediateTag.host.name ], eventType );
		}
	
		/**
		 * Add Mediator By Event Type
		 */
		protected function addMediatorByEventType( mediateTag:MediateMetadataTag, method:Function, eventType:String ):void
		{
			var mediator:MediateQueue = new MediateQueue( mediateTag, method );
			
			mediatorsByEventType[ eventType ] ||= [];
			mediatorsByEventType[ eventType ].push( mediator );
			
			swiz.dispatcher.addEventListener( eventType, mediator.mediate, false, mediateTag.priority, true );
		}
		
		/**
		 * Remove Mediator By Event Type
		 */
		protected function removeMediatorByEventType( mediateTag:MediateMetadataTag, method:Function, eventType:String ):void
		{
			if ( mediatorsByEventType[ eventType ] is Array )
			{
				var mediatorIndex:int = 0;
				for each ( var mediator:MediateQueue in mediatorsByEventType[ eventType ] )
				{
					if ( mediator.method == method )
					{
						swiz.dispatcher.removeEventListener( eventType, mediator.mediate, false );
						
						mediatorsByEventType[ eventType ].splice( mediatorIndex, 1 );
						break;
					}
					
					mediatorIndex++;
				}			

				if ( mediatorsByEventType[ eventType ].length == 0 )
					delete mediatorsByEventType[ eventType ];
			}
		}
		
		/**
		 * Parse Event Type Expression
		 * 
		 * Processes an event type expression into an event type. Accepts a String specifying either the event type 
		 * (ex. 'type') or a class constant reference (ex. 'SomeEvent.TYPE').  If a class constant reference is specified,
		 * it will be evaluted to obtain its String value.
		 * 
		 * Class constant references are only supported in 'strict' mode.
		 * 
		 * @param value A String that defines a Event type expression.
		 * @returns The event type.
		 */
		protected function parseEventTypeExpression( value:String ):String
		{
			if ( swiz.config.strict && ClassConstant.isClassConstant( value ) )
			{
				return ClassConstant.getConstantValue( ClassConstant.getClass( value, swiz.config.eventPackages ), ClassConstant.getConstantName( value ) ); 
			}
			else
			{
				return value;
			}
		}
		
		/**
		 * Validate Mediate Metadata Tag
		 * 
		 * @param mediator The MediateMetadataTag
		 */
		protected function validateMediateMetadataTag( mediator:MediateMetadataTag ):Boolean
		{
			if ( ClassConstant.isClassConstant( mediator.event ) )
			{
				var eventClass:Class = ClassConstant.getClass( mediator.event, swiz.config.eventPackages );
				var descriptor:TypeDescriptor = TypeCache.getTypeDescriptor( eventClass );
				
				// TODO: Support DynamicEvent (skip validation) and Event subclasses (enforce validation).
				// TODO: flash.events.Event is returning 'true' for isDynamic - figure out workaround?
				
				var isDynamic:Boolean = ( descriptor.description.@isDynamic.toString() == "true" );
				if ( ! isDynamic )
				{
					for each ( var property:String in mediator.properties )
					{
						var variableList:XMLList = descriptor.description.factory.variable.( @name == property );
						var accessorList:XMLList = descriptor.description.factory.accessor.( @name == property );
						if ( variableList.length() == 0 && accessorList.length() == 0 )
						{
							throw new Error(  "Unable to mediate event: " + property + " does not exist as a property of " + getQualifiedClassName( eventClass ) + "." );
						}
					}
				}
			}
			
			return true;
		}
		
	}
}