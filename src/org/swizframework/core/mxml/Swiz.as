package org.swizframework.core.mxml
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	
	import org.swizframework.core.IBeanFactory;
	import org.swizframework.core.ISwizConfig;
	import org.swizframework.utils.DomainUtil;
	
	[DefaultProperty( "beanProviders" )]
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz extends org.swizframework.core.Swiz implements IMXMLObject
	{
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function Swiz( dispatcher:IEventDispatcher = null, config:ISwizConfig = null, beanFactory:IBeanFactory = null, beanProviders:Array = null, customProcessors:Array = null )
		{
			super( dispatcher, config, beanFactory, beanProviders, customProcessors );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @see mx.core.IMXMLObject#initialized
		 */
		public function initialized( document:Object, id:String ):void
		{
			if( document is IEventDispatcher && dispatcher == null )
			{
				dispatcher = IEventDispatcher( document );
				dispatcher.addEventListener( FlexEvent.PREINITIALIZE, handleContainerPreinitialize );
			}
		}
		
		/**
		 *
		 */
		protected function handleContainerPreinitialize( event:Event ):void
		{
			dispatcher.removeEventListener( FlexEvent.PREINITIALIZE, handleContainerPreinitialize );
			// set the current domain with DomainUtils, only if the dispatcher is a module. Will give a parent swiz instance a chance to set 
			// in case of swiz instances nested down in the display list of a module.
			domain = DomainUtil.getModuleDomain( dispatcher );
			// initialize
			init();
		}
	}
}
