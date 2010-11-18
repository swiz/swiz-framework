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
	import flash.utils.getQualifiedClassName;
	
	import mx.modules.Module;
	
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
		
		protected const ignoredClasses:RegExp = /^mx\.|^spark\.|^flash\.|^fl\.|__/;
		
		protected var swiz:ISwiz;
		
		/**
		 *
		 */
		protected var _parentBeanFactory:IBeanFactory;
		
		protected var _beans:Array = [];
		
		protected var removedDisplayObjects:Array = [];
		
		protected var isListeningForEnterFrame:Boolean = false;
		
		// ========================================
		// public properties
		// ========================================
		
		public function get beans():Array
		{
			return _beans;
		}
		
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
		public function setUp( swiz:ISwiz ):void
		{
			this.swiz = swiz;
			
			swiz.dispatcher.addEventListener( BeanEvent.ADD_BEAN, handleBeanEvent );
			swiz.dispatcher.addEventListener( BeanEvent.SET_UP_BEAN, handleBeanEvent );
			swiz.dispatcher.addEventListener( BeanEvent.TEAR_DOWN_BEAN, handleBeanEvent );
			swiz.dispatcher.addEventListener( BeanEvent.REMOVE_BEAN, handleBeanEvent );
			
			for each( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				addBeanProvider( beanProvider, false );
			}
			
			// bean setup has to be delayed until after all startup beans have been added
			for each( var bean:Bean in beans )
			{
				if( !( bean is Prototype ) )
					setUpBean( bean );
			}
			
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
			
			if( swiz.dispatcher )
			{
				// as long as the dispatcher is a view, set it up like any other view
				// this allows it to be automatically torn down if caught by tearDownEventHandler()
				if( swiz.dispatcher is DisplayObject )
					SwizManager.setUp( DisplayObject( swiz.dispatcher ) );
				else
					setUpBean( createBeanFromSource( swiz.dispatcher ) );
			}
		}
		
		public function tearDown():void
		{
			for each( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				removeBeanProvider( beanProvider );
			}
			
			swiz.dispatcher.removeEventListener( BeanEvent.ADD_BEAN, handleBeanEvent );
			swiz.dispatcher.removeEventListener( BeanEvent.SET_UP_BEAN, handleBeanEvent );
			swiz.dispatcher.removeEventListener( BeanEvent.TEAR_DOWN_BEAN, handleBeanEvent );
			swiz.dispatcher.removeEventListener( BeanEvent.REMOVE_BEAN, handleBeanEvent );
			
			swiz.dispatcher.removeEventListener( swiz.config.setUpEventType, setUpEventHandler, ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ) );
			swiz.dispatcher.removeEventListener( swiz.config.tearDownEventType, tearDownEventHandler, ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ) );
			
			if( "systemManager" in swiz.dispatcher && swiz.dispatcher[ "systemManager" ] != null && swiz.dispatcher[ "systemManager" ].hasEventListener( swiz.config.setUpEventType ) )
			{
				swiz.dispatcher[ "systemManager" ].removeEventListener( swiz.config.setUpEventType, setUpEventHandlerSysMgr, ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ) );
				swiz.dispatcher[ "systemManager" ].removeEventListener( swiz.config.tearDownEventType, tearDownEventHandler, ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ) );
			}
			
			logger.info( "BeanFactory torn down" );
		}
		
		public function createBeanFromSource( source:Object, beanName:String = null ):Bean
		{
			var bean:Bean = getBeanForSource( source );
			
			if( bean == null )
				bean = constructBean( source, beanName, swiz.domain );
			
			return bean;
		}
		
		public function getBeanForSource( source:Object ):Bean
		{
			for each( var bean:Bean in beans )
			{
				if( bean is Prototype && Prototype( bean ).singleton == false )
					continue;
				else if( bean.source === source )
					return bean;
			}
			
			return null;
		}
		
		public function addBeanProvider( beanProvider:IBeanProvider, autoSetUpBeans:Boolean = true ):void
		{
			var bean:Bean;
			
			// add all beans before setting them up, in case they rely on each other
			for each( bean in beanProvider.beans )
			{
				addBean( bean, false );
			}
			
			if( autoSetUpBeans )
			{
				for each( bean in beanProvider.beans )
				{
					if( !( bean is Prototype ) )
						setUpBean( bean );
				}
			}
		}
		
		public function addBean( bean:Bean, autoSetUpBean:Boolean = true ):Bean
		{
			bean.beanFactory = this;
			beans.push( bean );
			
			if( autoSetUpBean )
				setUpBean( bean );
			
			return bean;
		}
		
		public function removeBeanProvider( beanProvider:IBeanProvider ):void
		{
			for each( var bean:Bean in beanProvider.beans )
			{
				removeBean( bean );
			}
		}
		
		public function removeBean( bean:Bean ):void
		{
			if( beans.indexOf( bean ) < 0 )
			{
				logger.warn( "{0} not found in beans list. Cannot remove." );
			}
				
			tearDownBean( bean );
			bean.beanFactory = null;
			bean.typeDescriptor = null;
			bean.source = null;
			beans.splice( beans.indexOf( bean ), 1 );
			bean = null;
		}
		
		public function getBeanByName( name:String ):Bean
		{
			var foundBean:Bean = null;
			
			for each( var bean:Bean in beans )
			{
				if( bean.name == name )
				{
					foundBean = bean;
					break;
				}
			}
			
			if( foundBean != null && !( foundBean is Prototype ) && !foundBean.initialized )
				setUpBean( foundBean );
			else if( foundBean == null && parentBeanFactory != null )
				foundBean = parentBeanFactory.getBeanByName( name );
			
			return foundBean;
		}
		
		public function getBeanByType( beanType:Class ):Bean
		{
			var foundBean:Bean;
			
			var beanTypeName:String = getQualifiedClassName( beanType );
			
			for each( var bean:Bean in beans )
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
		 * Initialze Bean
		 */
		public function setUpBean( bean:Bean ):void
		{
			if( bean.initialized )
				return;
			
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
			
			bean.initialized = false;
		}
		
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Handle bean set up and tear down events.
		 */
		protected function handleBeanEvent( event:BeanEvent ):void
		{
			var existingBean:Bean = getBeanForSource( event.source );
			
			switch( event.type )
			{
				case BeanEvent.ADD_BEAN:
					if( existingBean )
						logger.warn( "{0} already exists as a bean. Ignoring ADD_BEAN request.", event.source.toString() );
					else
						addBean( constructBean( event.source, event.beanName, swiz.domain ) );
					break;
				
				case BeanEvent.SET_UP_BEAN:
					if( existingBean )
						if( existingBean.initialized )
							logger.warn( "{0} is already set up as a bean. Ignoring SET_UP_BEAN request.", event.source.toString() );
						else
							setUpBean( existingBean );
					else
						setUpBean( constructBean( event.source, event.beanName, swiz.domain ) );
					break;
				
				case BeanEvent.TEAR_DOWN_BEAN:
					if( existingBean )
						tearDownBean( existingBean );
					else
						tearDownBean( constructBean( event.source, null, swiz.domain ) );
					break;
				
				case BeanEvent.REMOVE_BEAN:
					if( existingBean )
						removeBean( existingBean );
					else
						logger.warn( "Could not find bean with {0} as its source. Ignoring REMOVE_BEAN request.", event.source.toString() );
					break;
			}
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
					if( className.indexOf( viewPackage ) == 0 && className.indexOf( "__" ) < 0 )
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
			if( event.target is ISetUpValidator && !( ISetUpValidator( event.target ).allowSetUp() ) )
				return;
			
			if( isPotentialInjectionTarget( event.target ) )
			{				
				var i:int = removedDisplayObjects.indexOf( event.target );
				
				if( i != -1 )
				{
					removedDisplayObjects.splice( i, 1 );
					
					if( removedDisplayObjects.length == 0 )
					{
						swiz.dispatcher.removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
						isListeningForEnterFrame = false;
					}
					
					return;
				}
				
				SwizManager.setUp( DisplayObject( event.target ) );
			}
		}
		
		/**
		 * Injection Event Handler defined on SysMgr
		 */
		protected function setUpEventHandlerSysMgr( event:Event ):void
		{
			// make sure the view is not a descendant of the main dispatcher
			// if it's not, it is a popup, so we pass it along for processing
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
			if( event.target is ITearDownValidator && !( ITearDownValidator( event.target ).allowTearDown() ) )
				return;
			
			if( SwizManager.wiredViews[event.target] || isPotentialInjectionTarget( event.target ) || event.target is Module )
			{
				addRemovedDisplayObject( DisplayObject( event.target ) );
			}
		}
		
		protected function addRemovedDisplayObject( displayObject:DisplayObject ):void
		{
			if( removedDisplayObjects.indexOf( displayObject ) == -1 )
				removedDisplayObjects.push( displayObject );
			
			if( ! isListeningForEnterFrame )
			{
				swiz.dispatcher.addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
				isListeningForEnterFrame = true;
			}
		}
		
		protected function enterFrameHandler( event:Event ):void
		{
			swiz.dispatcher.removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
			isListeningForEnterFrame = false;
			
			var displayObject:DisplayObject = DisplayObject( removedDisplayObjects.shift() );
			
			while ( displayObject )
			{
				SwizManager.tearDown( displayObject );
				displayObject = DisplayObject( removedDisplayObjects.shift() );
			}
		}
		
		// ========================================
		// static methods
		// ========================================
		
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
