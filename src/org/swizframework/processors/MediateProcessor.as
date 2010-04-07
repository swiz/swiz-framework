package org.swizframework.processors
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.metadata.MediateMetadataTag;
	import org.swizframework.metadata.Mediator;
	import org.swizframework.reflection.ClassConstant;
	import org.swizframework.reflection.Constant;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.SwizLogger;
	
	/**
	 * Mediate Processor
	 */
	public class MediateProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const MEDIATE:String = "Mediate";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:ILogger = SwizLogger.getLogger( this );
		protected var mediatorsByEventType:Dictionary = new Dictionary();
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.MEDIATE;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function MediateProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ MEDIATE ] : metadataNames, MediateMetadataTag );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var mediateTag:MediateMetadataTag = metadataTag as MediateMetadataTag;
			
			if( validateMediateMetadataTag( mediateTag ) )
			{
				if( mediateTag.event.substr( -2 ) == ".*" )
				{
					var clazz:Class = ClassConstant.getClass( swiz.domain, mediateTag.event, swiz.config.eventPackages );
					var td:TypeDescriptor = TypeCache.getTypeDescriptor( clazz, swiz.domain );
					for each( var constant:Constant in td.constants )
						addMediatorByEventType( mediateTag, bean.source[ mediateTag.host.name ], constant.value );
				}
				else
				{
					var eventType:String = parseEventTypeExpression( mediateTag.event );
					addMediatorByEventType( mediateTag, bean.source[ mediateTag.host.name ], eventType );
				}
			}
			
			logger.debug( "MediateProcessor set up {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var mediateTag:MediateMetadataTag = metadataTag as MediateMetadataTag;
			var eventType:String = parseEventTypeExpression( mediateTag.event );
			
			removeMediatorByEventType( mediateTag, bean.source[ mediateTag.host.name ], eventType );
			
			logger.debug( "MediateProcessor tore down {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Mediator By Event Type
		 */
		protected function addMediatorByEventType( mediateTag:MediateMetadataTag, method:Function, eventType:String ):void
		{
			var mediator:Mediator = new Mediator( mediateTag, method );
			
			mediatorsByEventType[ eventType ] ||= [];
			mediatorsByEventType[ eventType ].push( mediator );
			
			var dispatcher:IEventDispatcher = swiz.config.defaultDispatcher == SwizConfig.LOCAL_DISPATCHER ? swiz.dispatcher : swiz.globalDispatcher;
			
			dispatcher.addEventListener( eventType, mediator.mediate, mediateTag.useCapture, mediateTag.priority, true );
			logger.debug( "MediateProcessor added listener to dispatcher for {0}, {1}", eventType, String( mediator.method ) );
		}
		
		/**
		 * Remove Mediator By Event Type
		 */
		protected function removeMediatorByEventType( mediateTag:MediateMetadataTag, method:Function, eventType:String ):void
		{	
			var dispatcher:IEventDispatcher = swiz.config.defaultDispatcher == SwizConfig.LOCAL_DISPATCHER ? swiz.dispatcher : swiz.globalDispatcher;
			
			if( mediatorsByEventType[ eventType ] is Array )
			{
				var mediatorIndex:int = 0;
				for each( var mediator:Mediator in mediatorsByEventType[ eventType ] )
				{
					if( mediator.method == method )
					{
						dispatcher.removeEventListener( eventType, mediator.mediate, mediateTag.useCapture );
						
						mediatorsByEventType[ eventType ].splice( mediatorIndex, 1 );
						break;
					}
					
					mediatorIndex++;
				}
				
				if( mediatorsByEventType[ eventType ].length == 0 )
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
		 * Validate Mediate Metadata Tag
		 *
		 * @param mediator The MediateMetadataTag
		 */
		protected function validateMediateMetadataTag( mediator:MediateMetadataTag ):Boolean
		{
			if( mediator.event == null || mediator.event.length == 0 )
			{
				throw new Error( "Missing \"event\" property in [Mediate] tag: " + mediator.asTag );
			}
			
			if( ClassConstant.isClassConstant( mediator.event ) )
			{
				var eventClass:Class = ClassConstant.getClass( swiz.domain, mediator.event, swiz.config.eventPackages );
				
				if( eventClass == null )
					throw new Error( "Could not get a reference to class for " + mediator.event + ". Did you specify its package in SwizConfig::eventPackages?" );
				
				var descriptor:TypeDescriptor = TypeCache.getTypeDescriptor( eventClass, swiz.domain );
				
				// TODO: Support DynamicEvent (skip validation) and Event subclasses (enforce validation).
				// TODO: flash.events.Event is returning 'true' for isDynamic - figure out workaround?
				
				var isDynamic:Boolean = ( descriptor.description.@isDynamic.toString() == "true" );
				if( ! isDynamic )
				{
					for each( var property:String in mediator.properties )
					{
						var variableList:XMLList = descriptor.description.factory.variable.( @name == property );
						var accessorList:XMLList = descriptor.description.factory.accessor.( @name == property );
						if( variableList.length() == 0 && accessorList.length() == 0 )
						{
							throw new Error( "Unable to mediate event: " + property + " does not exist as a property of " + getQualifiedClassName( eventClass ) + "." );
						}
					}
				}
			}
			
			return true;
		}
	
	}
}