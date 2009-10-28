package org.swizframework
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.di.AutowireManager;
	import org.swizframework.ioc.BeanManager;
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz
	{
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
		protected var beanManager:BeanManager;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Swiz( dispatcher:IEventDispatcher, config:SwizConfig = null )
		{
			this.autowireManager = new AutowireManager();
			this.beanManager = new BeanManager();
			
			this.dispatcher = dispatcher;
			this.dispatcher.addEventListener( injectionEvent, handleInjectionEvent, true, 50, true );
			
			this.config = ( config != null ) ? config : new SwizConfig()
			
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
			beanManager.processBeanProviders( providerClasses );
		}
	}
}