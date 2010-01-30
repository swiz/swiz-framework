package org.swizframework.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import mx.logging.ILogger;

	import org.swizframework.processors.IProcessor;
	import org.swizframework.processors.InjectProcessor;
	import org.swizframework.processors.MediateProcessor;
	import org.swizframework.processors.PostConstructProcessor;
	import org.swizframework.processors.VirtualBeanProcessor;
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

		/**
		 * Logger
		 */
		protected static var logger:ILogger = SwizLogger.getLogger( Swiz );


		// ben probably wants to move this!
		protected var _defaultFaultHandler:Function;

		protected var _dispatcher:IEventDispatcher;
		protected var _config:ISwizConfig;
		protected var _beanFactory:IBeanFactory;
		protected var _beanProviders:Array;
		protected var _processors:Array = [ new VirtualBeanProcessor(), new InjectProcessor(), 
			new PostConstructProcessor(), new MediateProcessor() ];

		// ========================================
		// public properties
		// ========================================

		/**
		 * @inheritDoc
		 */
		public function get defaultFaultHandler():Function
		{
			return _defaultFaultHandler;
		}

		public function set defaultFaultHandler(faultHandler:Function):void
		{
			_defaultFaultHandler = faultHandler;
		}

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

			constructProviders();

			beanFactory.init( this );
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

					if( providerInst is BeanLoader )
						BeanLoader(providerInst).initialize();

					beanProviders[ i ] = providerInst;
				}
			}
		}
	}
}
