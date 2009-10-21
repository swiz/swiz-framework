package org.swizframework
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.di.AutowireManager;
	
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
		
		// ========================================
		// constructor
		// ========================================
		
		public function Swiz( dispatcher:IEventDispatcher )
		{
			this.autowireManager = new AutowireManager();
			
			this.dispatcher = dispatcher;
			this.dispatcher.addEventListener( injectionEventType, handleInjectionEvent, true, 50, true );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * 
		 */
		protected function handleInjectionEvent( injectionEvent:Event ):void
		{
			autowireManager.autowire( injectionEvent.target );
		}
	}
}