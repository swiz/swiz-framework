package org.swizframework.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
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
		// protected properties
		// ========================================

		protected const ignoredClasses:RegExp = /^mx\.|^spark\.|^flash\.|^fl\./;

		protected var swiz:ISwiz;

		/**
		 *
		 */
		protected var typeDescriptors:Dictionary;

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

			swiz.processors.sortOn( "priority" );

			for each( var processor:IProcessor in swiz.processors )
			{
				processor.init( swiz );
			}

			addBeanProviders( swiz.beanProviders );

			swiz.dispatcher.addEventListener( swiz.config.injectionEvent, injectionEventHandler, ( swiz.config.injectionEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.injectionEventPriority, true );
			swiz.dispatcher.addEventListener( Event.REMOVED_FROM_STAGE, removeEventHandler, true, 50, true );
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
			for each( var bean:Bean in beanProvider.beans )
			{
				addBean( bean );
			}

			beanProvider.addEventListener( BeanEvent.ADDED, beanAddedHandler );
			beanProvider.addEventListener( BeanEvent.REMOVED, beanRemovedHandler );
		}

		/**
		 * Remove Bean Provider
		 */
		protected function removeBeanProvider( beanProvider:IBeanProvider ):void
		{
			for each( var bean:Bean in beanProvider.beans )
			{
				removeBean( bean );
			}

			beanProvider.removeEventListener( BeanEvent.ADDED, beanAddedHandler );
			beanProvider.removeEventListener( BeanEvent.REMOVED, beanRemovedHandler );
		}

		/**
		 * Add Bean
		 */
		protected function addBean( bean:Bean ):void
		{
			var processor:IProcessor;

			for each( processor in swiz.processors )
			{
				// Handle Metadata Processors
				if( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					
					// get the tags this processor is interested in
					var metadataTags:Array = [];
					for each( var metadataName:String in metadataProcessor.metadataNames )
					{
						metadataTags = metadataTags.concat( bean.typeDescriptor.getMetadataTagsByName( metadataName ) );
					}
					
					metadataProcessor.setUpMetadataTags( metadataTags, bean );
				}

				// Handle Bean Processors
				if( processor is IBeanProcessor )
				{
					IBeanProcessor( processor ).addBean( bean );
				}
			}
		}

		/**
		 * Remove Bean
		 */
		protected function removeBean( bean:Bean ):void
		{
			for each( var processor:IProcessor in swiz.processors )
			{
				// Handle Metadata Processors
				if( processor is IMetadataProcessor )
				{
					var metadataProcessor:IMetadataProcessor = IMetadataProcessor( processor );
					
					// get the tags this processor is interested in
					var metadataTags:Array = [];
					for each( var metadataName:String in metadataProcessor.metadataNames )
					{
						metadataTags = metadataTags.concat( bean.typeDescriptor.getMetadataTagsByName( metadataName ) );
					}

					metadataProcessor.setUpMetadataTags( metadataTags, bean );
				}

				// Handle Bean Processors
				if( processor is IBeanProcessor )
				{
					IBeanProcessor( processor ).removeBean( bean );
				}
			}
		}

		// TODO: Move to SwizConfig?

		/**
		 * Evaluate whether Swiz is configured such that the specified class is a potential injection target.
		 */
		protected function isPotentialInjectionTarget( instance:Object ):Boolean
		{
			if( swiz.config.injectionMarkerFunction != null )
			{
				return swiz.config.injectionMarkerFunction( instance );
			}
			else
			{
				var className:String = getQualifiedClassName( instance );

				if( swiz.config.viewPackages.length > 0 )
				{
					for each( var viewPackage:String in swiz.config.viewPackages )
					{
						if( className.indexOf( viewPackage ) == 0 )
							return true;
					}

					return false;
				}
				else
				{
					return ignoredClasses.test( className ) != true;
				}
			}
		}

		/**
		 * Injection Event Handler
		 */
		protected function injectionEventHandler( event:Event ):void
		{
			if( isPotentialInjectionTarget( event.target ) )
			{
				var bean:Bean = createBean( event.target );
				addBean( bean );
			}
		}

		/**
		 * Remove Event Handler
		 */
		protected function removeEventHandler( event:Event ):void
		{
			if( isPotentialInjectionTarget( event.target ) )
			{
				var bean:Bean = createBean( event.target );
				removeBean( bean );
			}
		}

		/**
		 * Bean Added Handler
		 */
		protected function beanAddedHandler( event:BeanEvent ):void
		{
			addBean( event.bean );
		}

		/**
		 * Bean Added Handler
		 */
		protected function beanRemovedHandler( event:BeanEvent ):void
		{
			removeBean( event.bean );
		}

		/**
		 * Create Bean
		 *
		 * @param instance An Object instance to introspect and wrap in a Bean.
		 * @returns The Bean representation of the Object instance.
		 */
		protected function createBean( instance:Object ):Bean
		{
			var bean:Bean = new Bean();

			bean.source = instance;

			// TODO: Is this necessary?
			if( "id" in bean.source && bean.source.id != null )
				bean.name = bean.source.id;

			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.source );

			return bean;
		}
	}
}