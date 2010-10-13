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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	import org.swizframework.events.SwizEvent;
	import org.swizframework.processors.DispatcherProcessor;
	import org.swizframework.processors.EventHandlerProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.processors.InjectProcessor;
	import org.swizframework.processors.PostConstructProcessor;
	import org.swizframework.processors.PreDestroyProcessor;
	import org.swizframework.processors.ProcessorPriority;
	import org.swizframework.processors.SwizInterfaceProcessor;
	import org.swizframework.utils.logging.AbstractSwizLoggingTarget;
	import org.swizframework.utils.logging.SwizLogger;
	
	[DefaultProperty( "beanProviders" )]
	[ExcludeClass]
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz extends EventDispatcher implements ISwiz
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:SwizLogger = SwizLogger.getLogger( this );
		
		protected var _dispatcher:IEventDispatcher;
		protected var _globalDispatcher:IEventDispatcher;
		protected var _domain:ApplicationDomain;
		
		protected var _config:ISwizConfig;
		protected var _beanFactory:IBeanFactory;
		protected var _beanProviders:Array;
		protected var _loggingTargets:Array;
		protected var _processors:Array = [ new InjectProcessor(), new DispatcherProcessor(), new EventHandlerProcessor(), 
											new SwizInterfaceProcessor(), new PostConstructProcessor(), new PreDestroyProcessor() ];
		
		protected var _parentSwiz:ISwiz;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher( value:IEventDispatcher ):void
		{
			_dispatcher = value;
			
			logger.info( "Swiz dispatcher set to {0}", value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get globalDispatcher():IEventDispatcher
		{
			return _globalDispatcher;
		}
		
		public function set globalDispatcher( value:IEventDispatcher ):void
		{
			_globalDispatcher = value;
			
			logger.info( "Swiz global dispatcher set to {0}", value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get domain():ApplicationDomain
		{
			return _domain;
		}
		
		public function set domain( value:ApplicationDomain ):void
		{
			_domain = value;
			
			logger.info( "Swiz domain set to {0}", value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get config():ISwizConfig
		{
			return _config;
		}
		
		public function set config( value:ISwizConfig ):void
		{
			_config = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get beanFactory():IBeanFactory
		{
			return _beanFactory;
		}
		
		public function set beanFactory( value:IBeanFactory ):void
		{
			_beanFactory = value;
		}
		
		[ArrayElementType( "org.swizframework.core.IBeanProvider" )]
		
		/**
		 * @inheritDoc
		 */
		public function get beanProviders():Array
		{
			return _beanProviders;
		}
		
		public function set beanProviders( value:Array ):void
		{
			_beanProviders = value;
		}
		
		[ArrayElementType( "org.swizframework.processors.IProcessor" )]
		
		/**
		 * @inheritDoc
		 */
		public function get processors():Array
		{
			return _processors;
		}
		
		public function set customProcessors( value:Array ):void
		{
			if( value != null )
			{
				/*
				 iterate over the incoming processors. if a new processor has the same
				 priority as a default processor, replace the built in one with the new one.
				 if the priority is default or anything else, simply add the processor.
				*/
				var processor:IProcessor;
				for( var i:int = 0; i < value.length; i++ )
				{
					processor = IProcessor( value[ i ] );
					if( processor.priority == ProcessorPriority.DEFAULT )
					{
						_processors.push( processor );
					}
					else
					{
						var found:Boolean = false;
						for( var j:int = 0; j < _processors.length; j++ )
						{
							if( IProcessor( _processors[ j ] ).priority == processor.priority )
							{
								_processors[ j ] = processor;
								found = true;
								break;
							}
						}
						
						if( !found ) _processors.push( processor );
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get parentSwiz():ISwiz
		{
			return _parentSwiz;
		}
		
		public function set parentSwiz( parentSwiz:ISwiz ):void
		{
			_parentSwiz = parentSwiz;
		}
		
		[ArrayElementType( "org.swizframework.utils.logging.AbstractSwizLoggingTarget" )]
		
		/**
		 * @inheritDoc
		 */
		public function get loggingTargets():Array
		{
			return _loggingTargets;
		}
		
		public function set loggingTargets( value:Array ):void
		{
			_loggingTargets = value;
			
			for each( var loggingTarget:AbstractSwizLoggingTarget in value )
			{
				SwizLogger.addLoggingTarget( loggingTarget );
			}
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function Swiz( dispatcher:IEventDispatcher = null, config:ISwizConfig = null, beanFactory:IBeanFactory = null, beanProviders:Array = null, customProcessors:Array = null )
		{
			super();
			
			this.dispatcher = dispatcher;
			this.config = config;
			this.beanFactory = beanFactory;
			this.beanProviders = beanProviders;
			this.customProcessors = customProcessors;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function registerWindow( window:IEventDispatcher, windowSwiz:ISwiz = null ):void
		{
			var newSwiz:ISwiz = ( windowSwiz != null ) ? windowSwiz : new Swiz( window );
			newSwiz.parentSwiz = this;
			
			if( windowSwiz == null )
				newSwiz.init();
		}
		
		/**
		 * Backing variable for <code>catchViews</code> getter/setter.
		 */
		protected var _catchViews:Boolean = true;
		
		/**
		 *
		 */
		public function get catchViews():Boolean
		{
			return _catchViews;
		}
		
		public function set catchViews( value:Boolean ):void
		{
			_catchViews = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function init():void
		{
			SwizManager.addSwiz( this );
			
			if( dispatcher == null )
			{
				dispatcher = this;
			}
			
			if( config == null )
			{
				config = new SwizConfig();
			}
			
			if( beanFactory == null )
			{
				beanFactory = new BeanFactory();
			}
			
			// dispatch a swiz created event before fully initializing
			dispatchSwizCreatedEvent();
			
			if( parentSwiz != null )
			{
				_beanFactory.parentBeanFactory = _parentSwiz.beanFactory;
				
				if( domain == null )
					domain = parentSwiz.domain;
				
				globalDispatcher = parentSwiz.globalDispatcher;
				
				config.eventPackages = config.eventPackages.concat( _parentSwiz.config.eventPackages );
				config.viewPackages = config.viewPackages.concat( _parentSwiz.config.viewPackages );
			}
			
			// set domain if it has not been set
			if( domain == null )
			{
				domain = ApplicationDomain.currentDomain;
			}
			
			// set global dispatcher if a parent wasn't able to set it
			if( globalDispatcher == null )
			{
				globalDispatcher = dispatcher;
			}
			
			constructProviders();
			
			initializeProcessors();
			
			beanFactory.setUp( this );
			
			logger.info( "Swiz initialized" );
		}
		
		/**
		 * Clean up this Swiz instance
		 */
		public function tearDown():void
		{
			// tear down any child views that have been wired
			SwizManager.tearDownAllWiredViewsForSwizInstance( this );
			
			// tear down beans defined in bean providers or added with BeanEvents
			beanFactory.tearDown();
			
			// clear out refs
			parentSwiz = null;
			SwizManager.removeSwiz( this );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		protected function initializeProcessors():void
		{
			processors.sortOn( "priority", Array.DESCENDING | Array.NUMERIC );
				
			for each( var processor:IProcessor in processors )
			{
				processor.init( this );
			}
			
			logger.debug( "Processors initialized" );
		}
		
		/**
		 * SwizConfig can accept bean providers as Classes as well as instances. ContructProviders
		 * ensures that provider is created and initialized before the bean factory accesses them.
		 */
		protected function constructProviders():void
		{
			var providerClass:Class;
			var providerInst:IBeanProvider;
			
			if( beanProviders == null )
				return;
			
			for( var i:int = 0; i < beanProviders.length; i++ )
			{
				// if the provider is a class, intantiate it, if a beanLoader, initialize
				// then replace the item in the array
				if( beanProviders[ i ] is Class )
				{
					providerClass = beanProviders[ i ] as Class;
					providerInst = new providerClass();
					beanProviders[ i ] = providerInst;
				}
				else
				{
					providerInst = beanProviders[ i ];
				}
				
				providerInst.initialize( domain );
			}
		}
		
		/**
		 * Dispatches a Swiz creation event to find parents and attaches a listener to
		 * find potential children.
		 */
		protected function dispatchSwizCreatedEvent():void
		{
			// dispatch a creation event to find parents
			dispatcher.dispatchEvent( new SwizEvent( SwizEvent.CREATED, this ) );
			// and attach a listener for children
			dispatcher.addEventListener( SwizEvent.CREATED, handleSwizCreatedEvent );
			
			logger.info( "Dispatched Swiz Created Event to find parent" );
		}
		
		/**
		 * Receives swiz creation events from potential child swiz instances, and sets this instance
		 * as the parent. Relies on display list ordering as a means of conveying parent / child
		 * relationships. Pure AS projects will need to call setParent explicitly.
		 */
		protected function handleSwizCreatedEvent( event:SwizEvent ):void
		{
			if( event.swiz != null  && event.swiz.parentSwiz == null )
			{
				event.swiz.parentSwiz = this;
			}
			
			logger.info( "Received SwizCreationEvent, set self to parent." );
		}
	}
}
