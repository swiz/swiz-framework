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

		/**
		 * Parent Swiz instance, for nesting and modules
		 */
		function get parentSwiz():ISwiz;
		function set parentSwiz(parentSwiz:ISwiz):void;

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
		
		/**
		 * Maybe better to extend bean provider interface
		 */
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
	}
}