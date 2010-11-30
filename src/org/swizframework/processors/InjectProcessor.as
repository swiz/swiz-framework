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
	import flash.utils.Dictionary;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.utils.UIDUtil;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwizAware;
	import org.swizframework.metadata.InjectMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	import org.swizframework.utils.logging.SwizLogger;
	import org.swizframework.utils.services.IServiceHelper;
	import org.swizframework.utils.services.IURLRequestHelper;
	import org.swizframework.utils.services.MockDelegateHelper;
	import org.swizframework.utils.services.ServiceHelper;
	import org.swizframework.utils.services.URLRequestHelper;
	
	/**
	 * Inject Processor
	 */
	public class InjectProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const INJECT:String = "Inject";
		protected static const AUTOWIRE:String = "Autowire";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:SwizLogger = SwizLogger.getLogger( this );
		protected var injectByProperty:Dictionary = new Dictionary();
		protected var sharedServiceHelper:IServiceHelper;
		protected var sharedURLRequestHelper:IURLRequestHelper;
		protected var sharedMockDelegateHelper:MockDelegateHelper;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.INJECT;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function InjectProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ INJECT, AUTOWIRE ] : metadataNames, InjectMetadataTag );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Inject
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var injectTag:InjectMetadataTag = metadataTag as InjectMetadataTag;
			
			if( injectTag.name == AUTOWIRE )
				logger.warn( "[Autowire] has been deprecated in favor of [Inject]. Please update {0} accordingly.", bean );
			
			// no source attribute means we're injecting by type
			if( injectTag.source == null )
			{
				addInjectByType( injectTag, bean );
			}
			else
			{
				// source attribute found - means we're injecting by name and potentially by property
				
				// try to obtain the bean by using the first part of the source attribute
				var namedBean:Bean = getBeanByName( injectTag.source.split( "." )[ 0 ] );
				
				if( namedBean == null )
				{
					// if the bean was not found and is required, throw an error
					// if it's been set to not required we log a warning that it wasn't available
					if( injectTag.required )
						throw new Error( "InjectionProcessorError: bean not found: " + injectTag.source );
					else
						logger.warn( "InjectProcessor could not fulfill {0} tag on {1}", injectTag.asTag, bean );
					
					// bail
					return;
				}
				
				// this is a view added to the display list or a new bean being processed
				var destObject:Object = ( injectTag.destination == null ) ? bean.source : getDestinationObject( bean.source, injectTag.destination );
				// name of property that will be bound to a source value
				var destPropName:* = getDestinationPropertyName( injectTag );
				
				var chain:String = injectTag.source.substr( injectTag.source.indexOf( "." ) + 1 );
				var bind:Boolean = injectTag.bind && ChangeWatcher.canWatch( namedBean.source, chain ) && !( destPropName is QName );
				
				// if injecting by name simply assign the bean's current value
				// as there is no context to create a binding
				if( injectTag.source.indexOf( "." ) < 0 )
				{
					setDestinationValue( injectTag, bean, namedBean.source );
				}
				else if( !bind )
				{
					// if tag specified no binding or property is not bindable, do simple assignment
					var sourceObject:Object = getDestinationObject( namedBean.source, chain );
					setDestinationValue( injectTag, bean, sourceObject[ injectTag.source.split( "." ).pop() ] );
					
					if( destPropName is QName && injectTag.bind == true )
					{
						var errorStr:String = "Cannot create a binding for " + metadataTag.asTag + " because " + injectTag.source.split( "." ).pop() + " is not public. ";
						errorStr += "Add bind=false to your Inject tag or make the property public.";
						throw new Error( errorStr );
					}
				}
				else
				{
					// bind to bean property
					addPropertyBinding( destObject, destPropName, namedBean.source, injectTag.source.split( "." ).slice( 1 ), injectTag.twoWay );
				}
			}
			
			logger.debug( "InjectProcessor set up {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		/**
		 * Remove Inject
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var injectTag:InjectMetadataTag = metadataTag as InjectMetadataTag;
			
			if( injectTag.source != null )
			{
				if( injectTag.source.indexOf( "." ) > -1 )
				{
					removeInjectByProperty( injectTag, bean );
				}
				else
				{
					removeInjectByName( injectTag, bean );
				}
			}
			else
			{
				removeInjectByType( injectTag, bean );
			}
			
			logger.debug( "InjectProcessor tore down {0} on {1}", metadataTag.toString(), bean.toString() );
		}
		
		/**
		 *
		 */
		protected function getDestinationObject( destObject:Object, chainString:String ):Object
		{
			var arr:Array = chainString.split( "." );
			var dest:Object = destObject;
			while( arr.length > 1 )
				dest = dest[ arr.shift() ];
			return dest;
		}
		
		/**
		 *
		 */
		protected function getDestinationPropertyName( injectTag:InjectMetadataTag ):*
		{
			if( injectTag.destination == null )
			{
				return injectTag.host.name;
			}
			else
			{
				return injectTag.destination.split( "." ).pop();
			}
		}
		
		/**
		 * Remove Inject By Property
		 */
		protected function removeInjectByProperty( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( injectTag.source.split( "." )[ 0 ] );
			
			removePropertyBinding( bean, namedBean, injectTag );
			
			setDestinationValue( injectTag, bean, null );
		}
		
		/**
		 * Remove Inject By Name
		 */
		protected function removeInjectByName( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			setDestinationValue( injectTag, bean, null );
		}
		
		/**
		 * Add Inject By Type
		 */
		protected function addInjectByType( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var setterInjection:Boolean = injectTag.host is MetadataHostMethod;
			var targetType:Class = ( setterInjection ) ? MethodParameter( MetadataHostMethod( injectTag.host ).parameters[ 0 ] ).type : injectTag.host.type;
			if( targetType == null && injectTag.host is MetadataHostClass )
			{
				targetType = swiz.domain.getDefinition( injectTag.host.name ) as Class;
			}
			var typedBean:Bean = getBeanByType( targetType );
			
			if( typedBean )
			{
				setDestinationValue( injectTag, bean, typedBean.source );
			}
			else
			{
				// helper classes can be created on demand so users don't have to declare them
				switch( targetType )
				{
					case ServiceHelper:
					case IServiceHelper:
						if( sharedServiceHelper == null )
						{
							sharedServiceHelper = new ServiceHelper();
							ISwizAware( sharedServiceHelper ).swiz = swiz;
						}
						
						setDestinationValue( injectTag, bean, sharedServiceHelper );
						return;
						
					case URLRequestHelper:
					case IURLRequestHelper:
						if( sharedURLRequestHelper == null )
						{
							sharedURLRequestHelper = new URLRequestHelper();
							ISwizAware( sharedURLRequestHelper ).swiz = swiz;
						}
						
						setDestinationValue( injectTag, bean, sharedURLRequestHelper );
						return;
						
					case MockDelegateHelper:
						if( sharedMockDelegateHelper == null )
							sharedMockDelegateHelper = new MockDelegateHelper();
						
						setDestinationValue( injectTag, bean, sharedMockDelegateHelper );
						return;
				}
				
				if( injectTag.required )
					throw new Error("InjectProcessor Error: bean of type " + targetType.toString() + " not found!" );
				else
					logger.warn( "Bean of type {0} not found, injection queues have been removed!", targetType.toString() );
			}
		}
		
		/**
		 * Remove Inject By Type
		 */
		protected function removeInjectByType( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			setDestinationValue( injectTag, bean, null );
		}
		
		/**
		 * Set Destination Value
		 */
		protected function setDestinationValue( injectTag:InjectMetadataTag, bean:Bean, value:* ):void
		{
			var setterInjection:Boolean = injectTag.host is MetadataHostMethod;
			
			var destObject:Object = ( injectTag.destination == null ) ? bean.source : getDestinationObject( bean.source, injectTag.destination );
			var destPropName:* = getDestinationPropertyName( injectTag );
			
			if( setterInjection )
			{
				var f:Function = destObject[ destPropName ] as Function;
				f.apply( destObject, [ value ] );
			}
			else
			{
				destObject[ destPropName ] = value;
			}
		}
		
		/**
		 * Get Bean By Name
		 */
		protected function getBeanByName( name:String ):Bean
		{
			return beanFactory.getBeanByName( name );
		}
		
		/**
		 * Get Bean By Type
		 */
		protected function getBeanByType( type:Class ):Bean
		{
			return beanFactory.getBeanByType( type );
		}
		
		/**
		 * Add Property Binding
		 */
		protected function addPropertyBinding( destObject:Object, destPropName:String, sourceObject:Object, sourcePropertyChain:Array, twoWay:Boolean = false ):void
		{
			var cw:ChangeWatcher;
			var uid:String;
			
			// we have to track any bindings we create so we can unwire them later if need be
			
			// get the uid of our view/new bean
			uid = UIDUtil.getUID( destObject );
			// create an array to store bindings for this object if one does not already exist
			injectByProperty[ uid ] ||= [];
			
			// if destObject[ destPropName ] is a write-only property, checking if its a function will throw an error
			try
			{
				// create and store this binding
				if( destObject[ destPropName ] is Function )
					injectByProperty[ uid ].push( BindingUtils.bindSetter( destObject[ destPropName ], sourceObject, sourcePropertyChain ) );
				else
					injectByProperty[ uid ].push( BindingUtils.bindProperty( destObject, destPropName, sourceObject, sourcePropertyChain ) );
			}
			catch( error:ReferenceError )
			{
				injectByProperty[ uid ].push( BindingUtils.bindProperty( destObject, destPropName, sourceObject, sourcePropertyChain ) );
				
				if( twoWay )
				{
					logger.error( "Cannot create twoWay binding for {0} property on {1} because it is write-only.", destPropName, destObject );
					return;
				}
			}
			
			// if twoWay binding was requested we have to do things in reverse
			// meaning the existing bean's property will also be bound to the view/new bean's property
			if( twoWay )
			{
				// can't use twoWay with a setter
				if( destObject[ destPropName ] is Function )
				{
					logger.error( "Cannot create twoWay binding for {0} method on {1} because methods cannot be binding sources.", destPropName, destObject );
					return;
				}
				
				// walk the object chain to reach the actual destination object
				while( sourcePropertyChain.length > 1 )
					sourceObject = sourceObject[ sourcePropertyChain.shift() ];
				// the last token of the source attribute is the actual property name
				var sourcePropName:String = sourcePropertyChain[ 0 ];
				
				// create the reverse binding where the view/new bean is the source
				if( ChangeWatcher.canWatch( destObject, destPropName ) )
				{
					// if a destination was provided we can use it as the host chain value
					injectByProperty[ uid ].push( BindingUtils.bindProperty( sourceObject, sourcePropName, destObject, destPropName ) );
				}
				else
				{
					logger.error( "Cannot create twoWay binding for {0} property on {1} because it is not bindable.", destPropName, destObject );
				}
			}
		}
		
		/**
		 * Remove Property Binding
		 */
		protected function removePropertyBinding( destination:Bean, source:Bean, injectTag:InjectMetadataTag ):void
		{
			var destObject:Object = ( injectTag.destination == null ) ? destination.source : getDestinationObject( destination.source, injectTag.destination );
			var uid:String = UIDUtil.getUID( destObject );
			for each( var cw:ChangeWatcher in injectByProperty[ uid ] )
			{
				cw.unwatch();
			}
			delete injectByProperty[ uid ];
		}
	}
}
