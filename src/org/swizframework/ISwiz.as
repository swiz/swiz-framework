package org.swizframework
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.IBeanFactory;
	
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
		function set processors( value:Array ):void;
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called once in initialize Swiz
		 */
		function init():void;
		
	}
}