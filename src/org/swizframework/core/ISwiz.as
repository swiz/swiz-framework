package org.swizframework.core
{
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	/**
	 * Swiz Interface
	 */
	public interface ISwiz
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Local Dispatcher
		 */
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;
		
		/**
		 * Global Dispatcher
		 */
		function get globalDispatcher():IEventDispatcher;
		function set globalDispatcher( value:IEventDispatcher ):void;
		
		/**
		 * Domain
		 */
		function get domain():ApplicationDomain;
		function set domain( value:ApplicationDomain ):void;
		
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
		function setProcessors( value:Array ):void;
		
		/**
		 * Custom Processors
		 */
		function set customProcessors( value:Array ):void;
		
		/**
		 * Parent Swiz instance, for nesting and modules
		 */
		function get parentSwiz():ISwiz;
		function set parentSwiz( parentSwiz:ISwiz ):void;
		
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
		 * Clean up this Swiz instance
		 */
		function tearDown():void;
	}
}