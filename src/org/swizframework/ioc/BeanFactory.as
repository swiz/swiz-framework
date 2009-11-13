package org.swizframework.ioc
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.ISwiz;
	import org.swizframework.events.BeanEvent;
	import org.swizframework.metadata.Metadata;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.util.MetadataUtil;
	
	/**
	 * Bean Factory
	 */
	public class BeanFactory extends EventDispatcher implements IBeanFactory
	{
		
		// ========================================
		// private properties
		// ========================================
		
		private var _injectionEvent:String = "addedToStage";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var swiz:ISwiz;
		protected var ignoredClasses:RegExp = /^mx\./;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function get injectionEvent():String
		{
			return _injectionEvent;
		}
		
		public function set injectionEvent( value:String ):void
		{
			_injectionEvent = value;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanFactory()
		{
			super();
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function init( swiz:ISwiz ):void
		{
			this.swiz = swiz;
			
			for each ( var processor:IProcessor in swiz.processors )
			{
				processor.init( swiz );
			}
			
			addBeanProviders( swiz.beanProviders );
			
			swiz.dispatcher.addEventListener( injectionEvent, injectionEventHandler, true, 50, true );
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Add Bean Providers
		 */
		protected function addBeanProviders( beanProviders:Array ):void
		{
			for each( var beanProvider:IBeanProvider in beanProviders )
			{
				addBeanProvider( beanProvider );
			}
		}
		
		/**
		 * Add Bean Provider
		 */
		protected function addBeanProvider( beanProvider:IBeanProvider ):void
		{
			for each ( var bean:Object in beanProvider.beans )
			{
				addBean( bean );
			}
			
			beanProvider.addEventListener( BeanEvent.ADDED, beanAddedHandler );
		}
		
		/**
		 * Remove Bean Provider
		 */
		protected function removeBeanProvider( beanProvider:IBeanProvider ):void
		{
			for each ( var bean:Object in beanProvider.beans )
			{
				removeBean( bean );
			}
			
			beanProvider.removeEventListener( BeanEvent.REMOVED, beanRemovedHandler );
		}
		
		/**
		 * Add Bean
		 */
		protected function addBean( bean:Object ):void
		{
			for each ( var processor:IProcessor in swiz.processors )
			{
				// Handle Bean Processors
				if ( processor is IBeanProcessor )
				{
					var beanProcessor:IBeanProcessor = IBeanProcessor( processor );
					
					beanProcessor.addBean( bean );
				}
				
				// Handle Metadata Processors
				if ( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					var metadatas:Array = MetadataUtil.findMetadataByName( bean, metadataProcessor.metadataName, metadataProcessor.metadataClass );
					
					for each ( var metadata:Metadata in metadatas )
					{
						metadataProcessor.addMetadata( bean, metadata );
					}
				}
			}
		}
		
		/**
		 * Remove Bean
		 */
		protected function removeBean( bean:Object ):void
		{
			for each ( var processor:IProcessor in swiz.processors )
			{
				// Handle Metadata Processors
				if ( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					var metadatas:Array = MetadataUtil.findMetadataByName( bean, metadataProcessor.metadataName, metadataProcessor.metadataClass );
					
					for each ( var metadata:Metadata in metadatas )
					{
						metadataProcessor.removeMetadata( bean, metadata );
					}
				}
				
				// Handle Bean Processors
				if ( processor is IBeanProcessor )
				{
					var beanProcessor:IBeanProcessor = IBeanProcessor( processor );
					
					beanProcessor.removeBean( bean );
				}
			}
		}
		
		/**
		 * Injection Event Handler
		 */
		protected function injectionEventHandler( event:Event ):void
		{
			var className:String = getQualifiedClassName( event.target );
			
			if ( ! ignoredClasses.test( className ) )
			{
				addBean( event.target );
			}
		}
		
		// ========================================
		// private methods
		// ========================================
		
		/**
		 * Bean Added Handler
		 */
		private function beanAddedHandler( event:BeanEvent ):void
		{
			addBean( event.bean );
		}
		
		/**
		 * Bean Added Handler
		 */
		private function beanRemovedHandler( event:BeanEvent ):void
		{
			removeBean( event.bean );
		}
	}
}