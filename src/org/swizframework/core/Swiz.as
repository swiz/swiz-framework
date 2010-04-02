package org.swizframework.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	import mx.logging.ILogger;
	import mx.logging.ILoggingTarget;
	import mx.modules.Module;
	import mx.modules.ModuleManager;
	
	import org.swizframework.events.SwizEvent;
	import org.swizframework.processors.DispatcherProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.processors.InjectProcessor;
	import org.swizframework.processors.MediateProcessor;
	import org.swizframework.processors.PostConstructProcessor;
	import org.swizframework.processors.PreDestroyProcessor;
	import org.swizframework.processors.SwizInterfaceProcessor;
	import org.swizframework.utils.SwizLogger;
	
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
		
		protected var logger:ILogger = SwizLogger.getLogger( this );
		
		protected var _dispatcher:IEventDispatcher;
		protected var _domain:ApplicationDomain;
		
		protected var _config:ISwizConfig;
		protected var _beanFactory:IBeanFactory;
		protected var _beanProviders:Array;
		protected var _loggingTargets:Array;
		protected var _processors:Array = [ new InjectProcessor(), new DispatcherProcessor(), new MediateProcessor(), 
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
				_processors = _processors.concat( value );
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
			_beanFactory.parentBeanFactory = _parentSwiz.beanFactory;
			
			config.eventPackages = config.eventPackages.concat( _parentSwiz.config.eventPackages );
			config.viewPackages = config.viewPackages.concat( _parentSwiz.config.viewPackages );
		}
		
		[ArrayElementType( "mx.logging.ILoggingTarget" )]
		
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
			
			for each( var loggingTarget:ILoggingTarget in value )
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
		
		/**
		 * @inheritDoc
		 */
		public function init():void
		{
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
			
			findDomain();
			
			constructProviders();
			
			initializeProcessors();
			
			beanFactory.init( this );
			
			beanFactory.setUpBeans();
			
			logger.info( "Swiz initialized" );
		}
		
		// ========================================
		// private methods
		// ========================================
		
		private function initializeProcessors():void
		{
			processors.sortOn( "priority" );
			
			for each( var processor:IProcessor in processors )
			{
				processor.init( this );
			}
			
			logger.debug( "Processors initialized" );
		}
		
		private function findDomain():void
		{
			// if the parent dispatcher is a module, get the application domain from the module manager
			// if not, we'll try to trust current domain
			if( dispatcher is Module )
			{
				var moduleInfo : Object = ModuleManager.getAssociatedFactory( dispatcher ).info();
				domain = moduleInfo.currentDomain;
			}
			else
			{
				domain = ApplicationDomain.currentDomain;
			}
		}
		
		/**
		 * SwizConfig can accept bean providers as Classes as well as instances. ContructProviders
		 * ensures that provider is created and initialized before the bean factory accesses them.
		 */
		private function constructProviders():void
		{
			var providerClass:Class;
			var providerInst:IBeanProvider;
			
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
				
				// now all BeanProviders require initialization
				providerInst.initialize( domain );
			}
		}
		
		/**
		 * Dispatches a Swiz creation event to find parents and attaches a listener to
		 * find potential children.
		 */
		private function dispatchSwizCreatedEvent():void
		{
			// dispatch a creation event to find parents
			dispatcher.dispatchEvent( new SwizEvent( SwizEvent.CREATED, this ) );
			// and attach a listener for children
			dispatcher.addEventListener( SwizEvent.CREATED, handleSwizCreatedEvent );
			
			logger.info( "Dispatched Swiz Created Event to find parents" );
		}
		
		/**
		 * Receives swiz creation events from potential child swiz instances, and sets this instance
		 * as the parent. Relies on display list ordering as a means of conveying parent / child
		 * relationships. Pure AS projects will need to call setParent explicitly.
		 */
		private function handleSwizCreatedEvent(event:SwizEvent):void
		{
			if( event.swiz != null )
			{
				event.swiz.parentSwiz = this;
			}
			
			logger.info( "Received SwizCreationEvent, set self to parent." );
		}
	}
}
