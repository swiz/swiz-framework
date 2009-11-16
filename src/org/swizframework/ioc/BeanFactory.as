package org.swizframework.ioc
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.swizframework.ISwiz;
	import org.swizframework.di.Bean;
	import org.swizframework.events.BeanEvent;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeCache;
	
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
		
		/**
		 * 
		 */
		protected var typeDescriptors:Dictionary;
		
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
			for each ( var bean:Bean in beanProvider.beans )
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
			for each ( var bean:Bean in beanProvider.beans )
			{
				removeBean( bean );
			}
			
			beanProvider.removeEventListener( BeanEvent.REMOVED, beanRemovedHandler );
		}
		
		/**
		 * Add Bean
		 */
		protected function addBean( bean:Bean ):void
		{
			var processor:IProcessor;
			
			for each ( processor in swiz.processors )
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
					var metadataTagClass:Class = metadataProcessor.metadataClass;
					// get the tags this processor is interested in
					var metadataTags:Array = bean.typeDescriptor.getMetadataTagsByName( metadataProcessor.metadataName );
					
					for each ( var metadataTag:IMetadataTag in metadataTags )
					{
						// if this processor operates on a custom tag we create it here
						if( metadataTagClass != BaseMetadataTag )
						{
							metadataProcessor.addMetadata( bean, new metadataTagClass( metadataTag.args, metadataTag.host ) );
						}
						else
						{
							metadataProcessor.addMetadata( bean, metadataTag );
						}
					}
				}
			}
		}
		
		/**
		 * Remove Bean
		 */
		protected function removeBean( bean:Bean ):void
		{
			for each ( var processor:IProcessor in swiz.processors )
			{
				// Handle Metadata Processors
				if ( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					var metadataTags:Array = bean.typeDescriptor.getMetadataTagsByName( metadataProcessor.metadataName );
					
					for each ( var metadataTag:IMetadataTag in metadataTags )
					{
						metadataProcessor.removeMetadata( bean, metadataTag );
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
				// wrap view component in Bean
				var bean:Bean = new Bean();
				bean.source = event.target;
				// is this pointless?
				if( "id" in bean.source && bean.source.id != null )
					bean.name = bean.source.id;
				bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.source );
				addBean( bean );
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