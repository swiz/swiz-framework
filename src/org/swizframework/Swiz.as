package org.swizframework
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.di.AutowireManager;
	import org.swizframework.ioc.BeanManager;
	
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
		protected var injectionEventType:String = "addedToStage";
		
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
		
		public function Swiz( dispatcher:IEventDispatcher )
		{
			this.autowireManager = new AutowireManager();
			this.beanManager = new BeanManager();
			
			this.dispatcher = dispatcher;
			this.dispatcher.addEventListener( injectionEventType, handleInjectionEvent, true, 50, true );
			
			if( dispatcher is ISwizHost )
				ISwizHost( dispatcher ).swizInstance = this;
			
			trace( "Swiz created and attached to", dispatcher );
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
			trace( "Swiz passing array of", providerClasses.length, "bean provider classes to BeanManager" );
			beanManager.processBeanProviders( providerClasses );
		}
	}
}