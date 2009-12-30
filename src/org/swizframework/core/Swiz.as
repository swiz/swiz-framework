package org.swizframework.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.logging.ILogger;
	
	import org.swizframework.processors.AutowireProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.processors.MediateProcessor;
	import org.swizframework.processors.VirtualBeanProcessor;
	import org.swizframework.util.SwizLogger;
	
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
		 * 
		 */
		protected static var logger:ILogger = SwizLogger.getLogger( Swiz );
		
		// ben probably wants to move this!
		protected var _defaultFaultHandler:Function;
		protected var _dispatcher:IEventDispatcher;
		protected var _beanFactory:IBeanFactory;
		protected var _beanProviders:Array;
		protected var _processors:Array = [ new AutowireProcessor(), new MediateProcessor(), new VirtualBeanProcessor() ];
		
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
		public function Swiz( dispatcher:IEventDispatcher = null, beanFactory:IBeanFactory = null, beanProviders:Array = null, customProcessors:Array = null )
		{
			super();
			
			this.dispatcher = dispatcher;
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
			if ( dispatcher == null )
			{
				dispatcher = this;
			}
			
			if ( beanFactory == null )
			{
				beanFactory = new BeanFactory();
			}
			
			beanFactory.init( this );
		}
	}
}
