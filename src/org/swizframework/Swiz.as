package org.swizframework
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.targets.TraceTarget;
	
	import org.swizframework.di.AutowireManager;
	import org.swizframework.ioc.BeanFactory;
	import org.swizframework.util.SwizLogger;
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz
	{
		/**
		 * 
		 */
		protected static var logger:ILogger = SwizLogger.getLogger( Swiz );
		
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * 
		 */
		protected var dispatcher:IEventDispatcher;
		
		/**
		 * 
		 */
		protected var config:SwizConfig;
		
		/**
		 * 
		 */
		protected var injectionEvent:String = "addedToStage";
		
		/**
		 * 
		 */
		protected var autowireManager:AutowireManager;
		
		/**
		 * 
		 */
		protected var beanManager:BeanFactory;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Swiz( dispatcher:IEventDispatcher, config:SwizConfig = null )
		{
			this.autowireManager = new AutowireManager();
			this.beanManager = new BeanFactory();
			
			this.dispatcher = dispatcher;
			
			this.dispatcher.addEventListener( injectionEvent, handleInjectionEvent, true, 50, true );
			
			this.config = ( config != null ) ? config : new SwizConfig()
			
//			var tt:TraceTarget = new TraceTarget();
//			tt.includeCategory = tt.includeLevel = true;
//			tt.fieldSeparator = " - ";
//			SwizLogger.setLogTargets( [ tt ] );
			
			if( dispatcher is ISwizHost )
				ISwizHost( dispatcher ).swizInstance = this;
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * 
		 */
		protected function handleInjectionEvent( injectionEvent:Event ):void
		{
			//autowireManager.autowire( injectionEvent.target, true );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function addBeanProviders( providerClasses:Array ):void
		{
			logger.debug( "Processing bean provider classes {0}", providerClasses );
			beanManager.processBeanProviders( providerClasses );
		}
	}
}