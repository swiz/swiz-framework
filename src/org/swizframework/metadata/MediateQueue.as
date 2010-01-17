package org.swizframework.metadata
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	
	public class MediateQueue
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>metadata</code> property.
		 */
		protected var _metadata:MediateMetadataTag;

		/**
		 * Backing variable for <code>method</code> property.
		 */
		protected var _method:Function;

		// ========================================
		// public properties
		// ========================================

		/**
		 * Mediate Metadata Tag
		 */
		public function get metadata():MediateMetadataTag
		{
			return _metadata;
		}
		
		/**
		 * Mediated Method
		 */
		public function get method():Function
		{
			return _method;
		}

		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function MediateQueue( metadata:MediateMetadataTag, method:Function )
		{
			_metadata = metadata;
			_method = method;
		}

		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Mediate
		 * 
		 * @param event The Event to mediate.
		 */
		public function mediate( event:Event ):void
		{
			if ( metadata.properties != null )
			{
				if ( validateEvent( event, metadata.properties ) )
					method.apply( null, getEventArgs( event, metadata.properties ) );
			}
			else if ( getRequiredParameterCount() <= 1 )
			{
				if ( event is getParameterType( 0 ) )
					method.apply( null, [ event ] );
				else
					method.apply();
			}
			else
			{
				throw new Error( "Unable to mediate event: " + metadata.host.name + "() requires " + getRequiredParameterCount() + " parameters, and no properties were specified." ); 
			}
			
			if ( metadata.stopPropagation )
				event.stopPropagation();
			
			if ( metadata.stopImmediatePropagation )
				event.stopImmediatePropagation();
		}

		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Validate Event
		 * 
		 * Evalutes an Event to ensure it has all of the required properties specified in the [Mediate] tag, if applicable.
		 * 
		 * @param event The Event to evalute
		 * @param mediator The MediateMetadataTag
		 */
		protected function validateEvent( event:Event, properties:Array ):Boolean
		{
			for each ( var property:String in properties )
			{
				if ( event.hasOwnProperty( property ) )
					throw new Error(  "Unable to mediate event: " + property + " does not exist as a property of " + getQualifiedClassName( event ) + "." );
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
			
			for each ( var property:String in properties )
			{
				args[ args.length ] = event[ property ];
			}
			
			return args;
		}
		
		/**
		 * Get Required Parameter Count
		 * 
		 * @returns The number of required parameters for the mediated method.
		 */
		protected function getRequiredParameterCount():int
		{
			var requiredParameterCount:int = 0;
			
			var parameters:Array = ( metadata.host as MetadataHostMethod ).parameters;
			for each ( var parameter:MethodParameter in parameters )
			{
				if ( parameter.optional )
					break;
					
				requiredParameterCount++;
			}
			
			return requiredParameterCount;
		}
		
		/**
		 * Get Parameter Type
		 * 
		 * @param parameterIndex The index of parameter of the mediated method.
		 * @returns The type for the specified parameter.
		 */
		protected function getParameterType( parameterIndex:int ):Class
		{
			var parameters:Array = ( metadata.host as MetadataHostMethod ).parameters;
			
			if ( parameterIndex < parameters.length )
				return ( parameters[ parameterIndex ] as MethodParameter ).type;
			
			return null;
		}
	}
}