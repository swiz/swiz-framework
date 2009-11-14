package org.swizframework
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	
	import org.swizframework.ioc.BeanFactory;
	import org.swizframework.ioc.IBeanFactory;
	import org.swizframework.processors.AutowireProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.processors.MediateProcessor;
	import org.swizframework.util.SwizLogger;
	
	[DefaultProperty( "beanProviders" )]
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz extends EventDispatcher implements IMXMLObject, ISwiz
	{
		/**
		 * 
		 */
		protected static var logger:ILogger = SwizLogger.getLogger( Swiz );
		
		// ========================================
		// private properties
		// ========================================
		
		private var _dispatcher:IEventDispatcher;
		private var _beanFactory:IBeanFactory;
		private var _beanProviders:Array;
		private var _processors:Array;
		
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
		
		[ArrayElementType( "org.swizframework.ioc.IBeanProvider" )]
		
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
		
		public function set processors( value:Array ):void
		{
			_processors = value;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function Swiz( dispatcher:IEventDispatcher = null, beanFactory:IBeanFactory = null, beanProviders:Array = null, processors:Array = null )
		{
			super();
			
			this.dispatcher = dispatcher;
			this.beanFactory = beanFactory;
			this.beanProviders = beanProviders;
			this.processors = processors;
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
				dispatcher == this;
			}
			
			if ( beanFactory == null )
			{
				beanFactory = new BeanFactory();
			}
			
			if ( processors == null )
			{
				processors = [ new AutowireProcessor(), new MediateProcessor() ];
			}
			
			beanFactory.init( this );
		}
		
		/**
		 * @see mx.core.IMXMLObject#initialized
		 */
		public function initialized( document:Object, id:String ):void
		{
			if ( document is IEventDispatcher && dispatcher == null )
			{
				dispatcher = IEventDispatcher( document );
			}
			
			init();
		}
		
	}
}
