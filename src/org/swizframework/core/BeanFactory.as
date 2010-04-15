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
	
	import mx.logging.ILogger;
	
	import org.swizframework.events.BeanEvent;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.utils.SwizLogger;
	
	/**
	 * Bean Factory
	 */
	public class BeanFactory extends EventDispatcher implements IBeanFactory
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:ILogger = SwizLogger.getLogger( this );
		
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
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter/setter.
		 */
		protected var _beans:Array = [];
		
		/**
		 * BeanFactories will pull all beans from BeanProviders into a local cache.
		 */
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
				swiz.dispatcher[ "systemManager" ].addEventListener( swiz.config.setUpEventType, setUpEventHandlerSysMgr, ( swiz.config.setUpEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.setUpEventPriority, true );
			
			swiz.dispatcher.addEventListener( swiz.config.tearDownEventType, tearDownEventHandler, ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.tearDownEventPriority, true );
			logger.debug( "Tear down event type set to {0}", swiz.config.tearDownEventType );
			logger.debug( "Tear down event phase set to {0}", ( swiz.config.tearDownEventPhase == EventPhase.CAPTURING_PHASE ) ? "capture phase" : "bubbling phase" );
			logger.debug( "Tear down event priority set to {0}", swiz.config.tearDownEventPriority );
		}
		
		/**
		 *
		 */
		protected function handleBeanEvent( event:BeanEvent ):void
		{
			var bean:Bean;
			
			if( event.type == BeanEvent.SET_UP_BEAN )
			{
				bean = constructBean( event.bean, event.beanName, swiz.domain );
				beans.push( bean );
				setUpBean( bean );
			}
			else
			{
				// get the right bean object
				for each( bean in beans )
				{
					if( event.bean == bean || event.bean == bean.source )
						tearDownBean( constructBean( event.bean, null, swiz.domain ) );
				}
					// TODO: log warning bean was not found
			}
		}
		
		public function getBeanByName( name:String ):Bean
		{
			var foundBean:Bean = null;
			
			for each( var bean:Bean in beans )
			{
				if( bean.name == name )
					foundBean = bean;
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
					_beans.push( bean );
				}
			}
		}
		
		/**
		 * Initializes all beans in the beans cache.
		 */
		public function setUpBeans():void
		{
			for each( var bean:Bean in beans )
			{
				if( !( bean is Prototype ) && !bean.initialized )
					setUpBean( bean );
			}
			
			SwizManager.setUp( DisplayObject( swiz.dispatcher ) );
		}
		
		/**
		 * Initialze Bean
		 */
		public function setUpBean( bean:Bean ):void
		{
			logger.debug( "BeanFactory::setUpBean( {0} )", bean );
			bean.initialized = true;
			if( beans.indexOf( bean ) < 0 )
				beans.push( bean );
			
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
		
		public function tearDownBeans():void
		{
			for each( var bean:Bean in beans )
			{
				tearDownBean( bean );
			}
		}
		
		/**
		 * Remove Bean
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
		}
		
		// TODO: Move to SwizConfig?
		
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
