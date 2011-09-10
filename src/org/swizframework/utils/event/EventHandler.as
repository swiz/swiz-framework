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

package org.swizframework.utils.event
{
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	
	import mx.rpc.AsyncToken;
	
	import org.swizframework.metadata.EventHandlerMetadataTag;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.async.AsyncTokenOperation;
	import org.swizframework.utils.async.IAsynchronousEvent;
	import org.swizframework.utils.async.IAsynchronousOperation;
	
	/**
	 * Represents a deferred request for mediation.
	 */
	public class EventHandler
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>metadata</code> property.
		 */
		protected var _metadataTag:EventHandlerMetadataTag;
		
		/**
		 * Backing variable for <code>method</code> property.
		 */
		protected var _method:Function;
		
		/**
		 * Backing variable for <code>eventClass</code> property.
		 */
		protected var _eventClass:Class;
		
		/**
		 * Backing variable for <code>domain</code> property.
		 */
		protected var _domain:ApplicationDomain;
		
		/**
		 * Strongly typed reference to metadataTag.host
		 */
		protected var hostMethod:MetadataHostMethod;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The corresponding [EventHandler] tag.
		 */
		public function get metadataTag():EventHandlerMetadataTag
		{
			return _metadataTag;
		}
		
		/**
		 * The function decorated with the [EventHandler] tag.
		 */
		public function get method():Function
		{
			return _method;
		}
		
		/**
		 * The Event class associated with the [EventHandler] tag's event type expression (if applicable).
		 */
		public function get eventClass():Class
		{
			return _eventClass;
		}
		
		/**
		 * The ApplicationDomain in which to operate.
		 */
		public function get domain():ApplicationDomain
		{
			return _domain;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function EventHandler( metadataTag:EventHandlerMetadataTag, method:Function, eventClass:Class, domain:ApplicationDomain )
		{
			_metadataTag = metadataTag;
			_method = method;
			_eventClass = eventClass;
			
			verifyTag();
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * HandleEvent
		 *
		 * @param event The Event to handle.
		 */
		public function handleEvent( event:Event ):void
		{
			// ignore if the event types do not match
			if( ( eventClass != null ) && !( event is eventClass ) )
				return;
			
			var result:* = null;
			
			if( metadataTag.properties != null )
			{
				if( validateEvent( event, metadataTag ) )
					result = method.apply( null, getEventArgs( event, metadataTag.properties ) );
			}
			else if( hostMethod.requiredParameterCount <= 1 )
			{
				if( hostMethod.parameterCount > 0 && event is getParameterType( 0 ) )
					result = method.apply( null, [ event ] );
				else
					result = method.apply();
			}
			
			if( event is IAsynchronousEvent && IAsynchronousEvent( event ).step != null )
			{
				if( result is IAsynchronousOperation )
					IAsynchronousEvent( event ).step.addAsynchronousOperation( result as IAsynchronousOperation );
				else if( result is AsyncToken )
					IAsynchronousEvent( event ).step.addAsynchronousOperation( new AsyncTokenOperation( result as AsyncToken ) );
			}
			
			if( metadataTag.stopPropagation )
				event.stopPropagation();
			
			if( metadataTag.stopImmediatePropagation )
				event.stopImmediatePropagation();
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		protected function verifyTag():void
		{
			hostMethod = MetadataHostMethod( metadataTag.host );
			
			if( metadataTag.properties == null && hostMethod.requiredParameterCount > 0 )
			{
				var eventClassDescriptor:TypeDescriptor = TypeCache.getTypeDescriptor( eventClass, domain );
				var parameterTypeName:String = getQualifiedClassName( getParameterType( 0 ) );
				
				if( eventClassDescriptor.satisfiesType( parameterTypeName ) == false )
					throw new Error( metadataTag.asTag + " is invalid. If you do not specify a properties attribute your method must either accept no arguments or an object compatible with the type specified in the tag." );
			}
			
			if( metadataTag.properties != null && ( metadataTag.properties.length < hostMethod.requiredParameterCount || metadataTag.properties.length > hostMethod.parameterCount ) )
				throw new Error( "The properties attribute of " + metadataTag.asTag + " is not compatible with the method signature of " + hostMethod.name + "()." );
		}
		
		/**
		 * Validate Event
		 *
		 * Evalutes an Event to ensure it has all of the required properties specified in the [EventHandler] tag, if applicable.
		 *
		 * @param event The Event to validate.
		 * @param properties The required properties specified in the [EventHandler] tag.
		 * @returns A Boolean value indicating whether the event has all of the required properties specified in the [EventHandler] tag.
		 */
		protected function validateEvent( event:Event, metadataTag:EventHandlerMetadataTag ):Boolean
		{
			for each( var property:String in metadataTag.properties )
			{
				if( property.indexOf( "." ) < 0 && !( property in event ) )
				{
					throw new Error( "Unable to handle event: " + property + " does not exist as a property of " + getQualifiedClassName( event ) + "." );
				}
				else
				{
					var chain:Array = property.split( "." );
					var o:Object = event;
					while( chain.length > 0 )
					{
						var prop:String = chain.shift();
						
						if( prop in o )
							o = o[ prop ];
						else
							throw new Error( "Unable to handle event: " + prop + " does not exist as a property of " + getQualifiedClassName( o ) + " as defined in " + metadataTag.asTag + "." );
					}
				}
			}
			
			return true;
		}
		
		/**
		 * Get Event Arguments
		 *
		 * @param event
		 * @param properties
		 */
		protected function getEventArgs( event:Event, properties:Array ):Array
		{
			var args:Array = [];
			
			for each( var property:String in properties )
			{
				if( property.indexOf( "." ) < 0 )
				{
					args[ args.length ] = event[ property ];
				}
				else
				{
					var chain:Array = property.split( "." );
					var o:Object = event;
					while( chain.length > 1 )
						o = o[ chain.shift() ];
					
					args[ args.length ] = o[ chain.shift() ];
				}
			}
			
			return args;
		}
		
		/**
		 * Get Parameter Type
		 *
		 * @param parameterIndex The index of parameter of the event handler method.
		 * @returns The type for the specified parameter.
		 */
		protected function getParameterType( parameterIndex:int ):Class
		{
			var parameters:Array = hostMethod.parameters;
			
			if( parameterIndex < parameters.length )
				return ( parameters[ parameterIndex ] as MethodParameter ).type;
			
			return null;
		}
	}
}