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

package org.swizframework.core
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.events.BeanEvent;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.utils.logging.SwizLogger;
	
	/**
	 * Bean Factory
	 */
	public class BeanFactory extends EventDispatcher implements IBeanFactory
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:SwizLogger = SwizLogger.getLogger( this );
		
		protected const ignoredClasses:RegExp = /^mx\.|^spark\.|^flash\.|^fl\./;
		
		protected var swiz:ISwiz;
		
		/**
		 *
		 */
		protected var typeDescriptors:Dictionary;
		
		/**
		 *
		 */
		protected var _parentBeanFactory:IBeanFactory;
		
		/**
		 * Backing dictionary for the cached bean instances.
		 */ 
		protected var _beanCache : Dictionary = new Dictionary();
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Returns the bean cache dictionary
		 */
		public function get beans():Dictionary
		{
			return _beanCache;
		}
		
		// ========================================
		// private properties
		// ========================================
		
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanFactory()
		{
			super();
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function init( swiz:ISwiz ):void
		{
			this.swiz = swiz;
			
			addBeanProviders( swiz.beanProviders );
			
			swiz.dispatcher.addEventListener( BeanEvent.SET_UP_BEAN, handleBeanEvent );
			swiz.dispatcher.addEventListener( BeanEvent.TEAR_DOWN_BEAN, handleBeanEvent );
			
			logger.info( "BeanFactory initialized" );
			
			if( swiz.catchViews == false )
				return;
			
			swiz.dispatcher.addEventListener( swiz.config.setUpEventType, setUpEventHandler, ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.setUpEventPriority, true );
			logger.debug( "Set up event type set to {0}", swiz.config.setUpEventType );
			logger.debug( "Set up event phase set to {0}", ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ) ? "capture phase" : "bubbling phase" );
			logger.debug( "Set up event priority set to {0}", swiz.config.setUpEventPriority );
			
			if( "systemManager" in swiz.dispatcher && swiz.dispatcher[ "systemManager" ] != null && !( swiz.dispatcher[ "systemManager" ].hasEventListener( swiz.config.setUpEventType ) ) )
			{
				swiz.dispatcher[ "systemManager" ].addEventListener( swiz.config.setUpEventType, setUpEventHandlerSysMgr, ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.setUpEventPriority, true );
				swiz.dispatcher[ "systemManager" ].addEventListener( swiz.config.tearDownEventType, tearDownEventHandler, ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.tearDownEventPriority, true );
			}
			
			swiz.dispatcher.addEventListener( swiz.config.tearDownEventType, tearDownEventHandler, ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.tearDownEventPriority, true );
			logger.debug( "Tear down event type set to {0}", swiz.config.tearDownEventType );
			logger.debug( "Tear down event phase set to {0}", ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ) ? "capture phase" : "bubbling phase" );
			logger.debug( "Tear down event priority set to {0}", swiz.config.tearDownEventPriority );
		}
		
		public function createBean( target:Object, beanName:String = null ):Bean
		{
			var bean:Bean = constructBean( target, beanName, swiz.domain );
			return addBean( bean );
		}
		
		public function addBean( bean:Bean ):Bean
		{
			// make sure bean is fully constructed
			if( bean.typeDescriptor == null )
				bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, swiz.domain );
			
			bean.beanFactory = this;
			_beanCache[ bean ] = bean;
			setUpBean( bean );
			return bean;
		}
		
		public function getBeanByName( name:String ):Bean
		{
			var foundBean:Bean = null;
			
			for each( var bean:Bean in _beanCache )
			{
				if( bean.name == name )
				{
					foundBean = bean;
					break;
				}
			}
			
			if( foundBean != null && !( foundBean is Prototype ) && !foundBean.initialized )
				setUpBean(foundBean);
			else if( foundBean == null && parentBeanFactory != null )
				foundBean = parentBeanFactory.getBeanByName( name );
			
			return foundBean;
		}
		
		public function getBeanByType( beanType:Class ):Bean
		{
			var foundBean:Bean;
			// should we just have sent in the className for beanType instead??
			var beanTypeName:String = getQualifiedClassName( beanType );
			
			for each( var bean:Bean in _beanCache )
			{
				if( bean.typeDescriptor.satisfiesType( beanTypeName ) )
				{
					if( foundBean != null )
					{
						throw new Error( "AmbiguousReferenceError. More than one bean was found with type: " + beanType );
					}
					
					foundBean = bean;
				}
			}
			
			if( foundBean != null && !( foundBean is Prototype ) && !foundBean.initialized )
				setUpBean( foundBean );
			else if( foundBean == null && parentBeanFactory != null )
				foundBean = parentBeanFactory.getBeanByType( beanType );
			
			return foundBean;
		}
		
		public function set parentBeanFactory( beanFactory:IBeanFactory ):void
		{
			_parentBeanFactory = beanFactory;
		}
		
		public function get parentBeanFactory():IBeanFactory
		{
			return _parentBeanFactory;
		}
		
		/**
		 * Initializes all beans in the beans cache.
		 */
		public function setUpBeans():void
		{
			for each( var bean:Bean in _beanCache )
			{
				if( !( bean is Prototype ) && !bean.initialized )
					setUpBean( bean );
			}
			
			// if the core dispatcher is a display object, set it up as well
			if ( swiz.dispatcher is DisplayObject )
				SwizManager.setUp( DisplayObject( swiz.dispatcher ) );
		}
		
		/**
		 * Initialze Bean
		 */
		public function setUpBean( bean:Bean ):void
		{
			logger.debug( "BeanFactory::setUpBean( {0} )", bean );
			bean.initialized = true;
			
			var processor:IProcessor;
			
			for each( processor in swiz.processors )
			{
				// Handle Metadata Processors
				if( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					
					// get the tags this processor is interested in
					var metadataTags:Array = [];
					for each( var metadataName:String in metadataProcessor.metadataNames )
					{
						metadataTags = metadataTags.concat( bean.typeDescriptor.getMetadataTagsByName( metadataName ) );
					}
					
					metadataProcessor.setUpMetadataTags( metadataTags, bean );
				}
				
				if( processor is IBeanProcessor )
				{
					IBeanProcessor( processor ).setUpBean( bean );
				}
			}
		}
		
		/**
		 * Tear down all beans and clear the bean cache
		 */ 
		public function tearDownBeans():void
		{
			for each( var bean:Bean in _beanCache )
			{
				tearDownBean( bean );
			}
			_beanCache = new Dictionary();
		}
		
		/**
		 * Tear down the specified Bean, or any bean with the same source, and remove it from the cache.
		 */
		public function tearDownBean( bean:Bean ):void
		{
			for each( var processor:IProcessor in swiz.processors )
			{
				// Handle Metadata Processors
				if( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					
					// get the tags this processor is interested in
					var metadataTags:Array = [];
					for each( var metadataName:String in metadataProcessor.metadataNames )
					{
						metadataTags = metadataTags.concat( bean.typeDescriptor.getMetadataTagsByName( metadataName ) );
					}
					
					metadataProcessor.tearDownMetadataTags( metadataTags, bean );
				}
				
				// Handle Bean Processors
				if( processor is IBeanProcessor )
				{
					IBeanProcessor( processor ).tearDownBean( bean );
				}
			}
			
			// remove the bean from the cache
			removeBean( bean );
		}
		
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Bean Providers
		 */
		protected function addBeanProviders( beanProviders:Array ):void
		{
			for each( var beanProvider:IBeanProvider in beanProviders )
			{
				for each( var bean:Bean in beanProvider.beans )
				{
					bean.beanFactory = this;
					if( bean is Prototype )
						_beanCache[ bean ] = bean;
					else
						_beanCache[ bean.source ] = bean;
				}
			}
		}
		
		
		/**
		 * Handle bean set up and tear down events.
		 */
		protected function handleBeanEvent( event:BeanEvent ):void
		{
			var bean:Bean;
			
			if( event.type == BeanEvent.SET_UP_BEAN )
			{
				// should we loop over the beans to see if we have this bean? 
				// ben says before the event type check
				if( !_beanCache[ event.bean ] ) 
				{
					createBean( event.bean, event.beanName );
				}
				else
				{
					logger.warn( "Attempted to set up a bean with the same source as an existing bean: {0}", event.bean.toString() );	
				}
			}
			else
			{
				// get the right bean object
				if( _beanCache[ event.bean ] )
				{
					tearDownBean( event.bean );
				}
				else
				{
					logger.warn( "Attempted to tear down undefined bean: {0}", event.bean.toString() );					
				}
			}
		}
		
		/**
		 * Remove matching bean from the cache
		 */ 
		protected function removeBean( bean : Bean ) : void
		{
			if( bean is Prototype )
				delete _beanCache[ bean ];
			else
				delete _beanCache[ bean.source ];
		}
		
		/**
		 * Evaluate whether Swiz is configured such that the specified class is a potential injection target.
		 */
		protected function isPotentialInjectionTarget( instance:Object ):Boolean
		{
			var className:String = getQualifiedClassName( instance );
			
			// new, for modules. if the current app domain does not have the definition we are 
			// looking for, we cannot even try to continue.
			if( !swiz.domain.hasDefinition( className ) )
			{
				return false;
			}
			else if( swiz.config.viewPackages.length > 0 )
			{
				for each( var viewPackage:String in swiz.config.viewPackages )
				{
					if( className.indexOf( viewPackage ) == 0 )
						return true;
				}
				
				return false;
			}
			else
			{
				return !( ignoredClasses.test( className ) );
			}
		}
		
		/**
		 * Injection Event Handler
		 */
		protected function setUpEventHandler( event:Event ):void
		{
			if( isPotentialInjectionTarget( event.target ) )
			{
				SwizManager.setUp( DisplayObject( event.target ) );
			}
		}
		
		/**
		 * Injection Event Handler defined on SysMgr
		 */
		protected function setUpEventHandlerSysMgr( event:Event ):void
		{
			// make sure the view is not a descendant of the main dispatcher
			// if its not, it is a popup, so we pass it along for processing
			if( !Sprite( swiz.dispatcher ).contains( DisplayObject( event.target ) ) )
			{
				setUpEventHandler( event );
			}
		}
		
		/**
		 * Remove Event Handler
		 */
		protected function tearDownEventHandler( event:Event ):void
		{
			if( isPotentialInjectionTarget( event.target ) )
			{
				SwizManager.tearDown( DisplayObject( event.target ) );
			}
		}

		
		// ========================================
		// static methods
		// ========================================

		
		// both init method and setBeanIds will call this if needed
		public static function constructBean( obj:*, name:String, domain:ApplicationDomain ):Bean
		{
			var bean:Bean;
			
			if( obj is Bean )
			{
				bean = Bean( obj );
			}
			else
			{
				bean = new Bean();
				bean.source = obj;
			}
			
			bean.name ||= name;
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, domain );
			
			return bean;
		}
	}
}
