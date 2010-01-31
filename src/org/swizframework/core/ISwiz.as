package org.swizframework.core
{
	import flash.events.IEventDispatcher;

	/**
	 * Swiz Interface
	 */
	public interface ISwiz
	{
		// ========================================
		// public properties
		// ========================================

		/**
		 * Default Fault Handler
		 */
		function get defaultFaultHandler():Function;
		function set defaultFaultHandler( faultHandler:Function ):void;

		/**
		 * Dispatcher
		 */
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;

		/**
		 * Config
		 */
		function get config():ISwizConfig;
		function set config( value:ISwizConfig ):void;

		[ArrayElementType( "org.swizframework.core.IBeanProvider" )]

		/**
		 * Bean Providers
		 */
		function get beanProviders():Array;
		function set beanProviders( value:Array ):void;

		/**
		 * Bean Factory
		 */
		function get beanFactory():IBeanFactory;
		function set beanFactory( value:IBeanFactory ):void;

		[ArrayElementType( "org.swizframework.processors.IProcessor" )]

		/**
		 * Processors
		 */
		function get processors():Array;

		/**
		 * Custom Processors
		 */
		function set customProcessors( value:Array ):void;

		[ArrayElementType( "mx.logging.ILoggingTarget" )]

		/**
		 * Logging targets
		 */
		function get loggingTargets():Array;
		function set loggingTargets( value:Array ):void;

		// ========================================
		// public methods
		// ========================================

		/**
		 * Called once in initialize Swiz
		 */
		function init():void;
	}
}