/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.processors
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.metadata.EventHandlerMetadataTag;
	import org.swizframework.metadata.EventTypeExpression;
	import org.swizframework.reflection.ClassConstant;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.event.EventHandler;
	import org.swizframework.utils.logging.SwizLogger;
	
	/**
	 * EventHandler Processor
	 */
	public class EventHandlerProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const EVENT_HANDLER:String = "EventHandler";
		protected static const MEDIATE:String = "Mediate";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:SwizLogger = SwizLogger.getLogger( this );
		protected var eventHandlersByEventType:Dictionary = new Dictionary();
		protected var eventHandlerClass:Class = EventHandler;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.EVENT_HANDLER;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function EventHandlerProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ EVENT_HANDLER, MEDIATE ] : metadataNames, EventHandlerMetadataTag );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var eventHandlerTag:EventHandlerMetadataTag = metadataTag as EventHandlerMetadataTag;
			
			if( eventHandlerTag.name == MEDIATE )
				logger.warn( "[Mediate] has been deprecated in favor of [EventHandler]. Please update {0} accordingly.", bean );
			
			if( validateEventHandlerMetadataTag( eventHandlerTag ) )
			{
				var expression:EventTypeExpression = new EventTypeExpression( eventHandlerTag.event, swiz );
				for each( var eventType:String in expression.eventTypes )
				{
					addEventHandlerByEventType( eventHandlerTag, bean.source[ eventHandlerTag.host.name ], expression.eventClass, eventType );
				}
			}
			
			logger.debug( "EventHandlerProcessor set up {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var eventHandlerTag:EventHandlerMetadataTag = metadataTag as EventHandlerMetadataTag;
			
			var expression:EventTypeExpression = new EventTypeExpression( eventHandlerTag.event, swiz );
			for each( var eventType:String in expression.eventTypes )
			{
				removeEventHandlerByEventType( eventHandlerTag, bean.source[ eventHandlerTag.host.name ], expression.eventClass, eventType );
			}
			
			logger.debug( "EventHandlerProcessor tore down {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Mediator By Event Type
		 */
		protected function addEventHandlerByEventType( eventHandlerTag:EventHandlerMetadataTag, method:Function, eventClass:Class, eventType:String ):void
		{
			var eventHandler:EventHandler = new eventHandlerClass( eventHandlerTag, method, eventClass );
			
			eventHandlersByEventType[ eventType ] ||= [];
			eventHandlersByEventType[ eventType ].push( eventHandler );
			
			var dispatcher:IEventDispatcher = null;
			
			// if the eventHandler tag defines a scope, set proper dispatcher, else use defaults
			if( eventHandlerTag.scope == SwizConfig.GLOBAL_DISPATCHER )
				dispatcher = swiz.globalDispatcher;
			else if( eventHandlerTag.scope == SwizConfig.LOCAL_DISPATCHER )
				dispatcher = swiz.dispatcher;
			else
				dispatcher = swiz.config.defaultDispatcher == SwizConfig.LOCAL_DISPATCHER ? swiz.dispatcher : swiz.globalDispatcher;
			
			dispatcher.addEventListener( eventType, eventHandler.handleEvent, eventHandlerTag.useCapture, eventHandlerTag.priority, true );
			logger.debug( "EventHandlerProcessor added listener to dispatcher for {0}, {1}", eventType, String( eventHandler.method ) );
		}
		
		/**
		 * Remove Mediator By Event Type
		 */
		protected function removeEventHandlerByEventType( eventHandlerTag:EventHandlerMetadataTag, method:Function, eventClass:Class, eventType:String ):void
		{	
			var dispatcher:IEventDispatcher = null;
			
			// if the eventHandler tag defines a scope, set proper dispatcher, else use defaults
			if( eventHandlerTag.scope == SwizConfig.GLOBAL_DISPATCHER )
				dispatcher = swiz.globalDispatcher;
			else if( eventHandlerTag.scope == SwizConfig.LOCAL_DISPATCHER )
				dispatcher = swiz.dispatcher;
			else
				dispatcher = swiz.config.defaultDispatcher == SwizConfig.LOCAL_DISPATCHER ? swiz.dispatcher : swiz.globalDispatcher;
			
			if( eventHandlersByEventType[ eventType ] is Array )
			{
				var eventHandlerIndex:int = 0;
				for each( var eventHandler:EventHandler in eventHandlersByEventType[ eventType ] )
				{
					if( ( eventHandler.method == method ) && ( eventHandler.eventClass == eventClass ) )
					{
						dispatcher.removeEventListener( eventType, eventHandler.handleEvent, eventHandlerTag.useCapture );
						
						eventHandlersByEventType[ eventType ].splice( eventHandlerIndex, 1 );
						break;
					}
					
					eventHandlerIndex++;
				}
				
				if( eventHandlersByEventType[ eventType ].length == 0 )
					delete eventHandlersByEventType[ eventType ];
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
			if( swiz.config.strict && ClassConstant.isClassConstant( value ) )
			{
				return ClassConstant.getConstantValue( swiz.domain, ClassConstant.getClass( swiz.domain, value, swiz.config.eventPackages ), ClassConstant.getConstantName( value ) );
			}
			else
			{
				return value;
			}
		}
		
		/**
		 * Validate EventHandler Metadata Tag
		 *
		 * @param mediator The EventHandlerMetadataTag
		 */
		protected function validateEventHandlerMetadataTag( eventHandlerTag:EventHandlerMetadataTag ):Boolean
		{
			if( eventHandlerTag.event == null || eventHandlerTag.event.length == 0 )
			{
				throw new Error( "Missing \"event\" property in [EventHandler] tag: " + eventHandlerTag.asTag );
			}
			
			if( ClassConstant.isClassConstant( eventHandlerTag.event ) )
			{
				var eventClass:Class = ClassConstant.getClass( swiz.domain, eventHandlerTag.event, swiz.config.eventPackages );
				
				if( eventClass == null )
					throw new Error( "Could not get a reference to class for " + eventHandlerTag.event + ". Did you specify its package in SwizConfig::eventPackages?" );
				
				var descriptor:TypeDescriptor = TypeCache.getTypeDescriptor( eventClass, swiz.domain );
				
				// TODO: Support DynamicEvent (skip validation) and Event subclasses (enforce validation).
				// TODO: flash.events.Event is returning 'true' for isDynamic - figure out workaround?
				
				var isDynamic:Boolean = ( descriptor.description.@isDynamic.toString() == "true" );
				if( ! isDynamic )
				{
					for each( var property:String in eventHandlerTag.properties )
					{
						var variableList:XMLList = descriptor.description.factory.variable.( @name == property );
						var accessorList:XMLList = descriptor.description.factory.accessor.( @name == property );
						if( variableList.length() == 0 && accessorList.length() == 0 )
						{
							throw new Error( "Unable to handle event: " + property + " does not exist as a property of " + getQualifiedClassName( eventClass ) + "." );
						}
					}
				}
			}
			
			return true;
		}
	
	}
}