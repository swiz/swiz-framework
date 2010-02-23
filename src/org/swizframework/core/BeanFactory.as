package org.swizframework.core
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	
	import org.swizframework.events.BeanEvent;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.utils.SwizLogger;
	
	/**
	 * Bean Factory
	 */
	public class BeanFactory extends EventDispatcher implements IBeanFactory
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var logger:ILogger = SwizLogger.getLogger( this );
		
		protected const ignoredClasses:RegExp = /^mx\.|^spark\.|^flash\.|^fl\./;
		
		protected var swiz:ISwiz;
		
		/**
		 *
		 */
		protected var typeDescriptors:Dictionary;
		
		/**
		 *
		 */
		protected var _parentBeanFactory:IBeanFactory;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter/setter.
		 */
		protected var _beans:Array = [];
		
		/**
		 * BeanFactories will pull all beans from BeanProviders into a local cache.
		 */
		public function get beans():Array
		{
			return _beans;
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
			
			addBeanProviders( swiz.beanProviders );
			
			swiz.dispatcher.addEventListener( swiz.config.injectionEvent, injectionEventHandler, ( swiz.config.injectionEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.injectionEventPriority, true );
			logger.debug( "Injection trigger event type set to {0}", swiz.config.injectionEvent );
			logger.debug( "Injection trigger event phase set to {0}", ( swiz.config.injectionEventPhase == EventPhase.CAPTURING_PHASE ) ? "capture phase" : "bubbling phase" );
			logger.debug( "Injection trigger event priority set to {0}", swiz.config.injectionEventPriority );
			
			if( "systemManager" in swiz.dispatcher )
				UIComponent( swiz.dispatcher ).systemManager.addEventListener( swiz.config.injectionEvent, injectionEventHandlerSysMgr, ( swiz.config.injectionEventPhase == EventPhase.CAPTURING_PHASE ), swiz.config.injectionEventPriority, true );
			
			swiz.dispatcher.addEventListener( Event.REMOVED_FROM_STAGE, removeEventHandler, true, 50, true );
			
			logger.info( "BeanFactory initialized" );
		}
		
		public function getBeanByName( name:String ):Bean
		{
			var foundBean:Bean = null;
			
			for each( var bean:Bean in beans )
			{
				if( bean.name == name )
					foundBean = bean;
			}
			
			if( foundBean != null && !( foundBean is Prototype ) && !foundBean.initialized )
				initializeBean(foundBean);
			else if( foundBean == null && parentBeanFactory != null )
				foundBean = parentBeanFactory.getBeanByName( name );
			
			return foundBean;
		}
		
		public function getBeanByType( beanType:Class ):Bean
		{
			var foundBean:Bean;
			
			for each( var bean:Bean in beans )
			{
				if( bean.type is beanType )
				{
					if ( foundBean != null )
					{
						throw new Error( "AmbiguousReferenceError. More than one bean was found with type: " + beanType );
					}
					
					foundBean = bean;
				}
			}
			
			if( foundBean != null && !( foundBean is Prototype ) && !foundBean.initialized )
				initializeBean( foundBean );
			else if( foundBean == null && parentBeanFactory != null )
				foundBean = parentBeanFactory.getBeanByType( beanType );
			
			return foundBean;
		}
		
		public function set parentBeanFactory( beanFactory:IBeanFactory ):void
		{
			_parentBeanFactory = beanFactory;
		}
		
		public function get parentBeanFactory():IBeanFactory
		{
			return _parentBeanFactory;
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
				beanProvider.dispatcher = swiz.dispatcher;
				for each( var bean:Bean in beanProvider.beans )
				{
					bean.beanFactory = this;
					_beans.push( bean );
				}
			}
		}
		
		/**
		 * Initializes all beans in the beans cache.
		 */
		public function initializeBeans():void
		{
			for each( var bean:Bean in beans )
			{
				if( !( bean is Prototype ) && !bean.initialized )
					initializeBean( bean );
			}
			
			// add main dispatcher as bean to collection
			var rootDispatcherBean:Bean = createBean( swiz.dispatcher );
			beans.push( rootDispatcherBean );
			// manually trigger processing now that all defined beans are done
			initializeBean( rootDispatcherBean );
		}
		
		/**
		 * Initialze Bean
		 */
		public function initializeBean( bean:Bean ):void
		{
			logger.debug( "BeanFactory::initializeBean( {0} )", bean );
			bean.initialized = true;
			
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
			}
			
			// if bean inplements ISwizInterface, handle those injections
			if( bean.type is ISwizInterface )
				handleSwizInterfaces( ISwizInterface( bean.type ) );
			
			// process all bean post-processors				
			for each( processor in swiz.processors )
			{
				// Handle Bean Processors
				if( processor is IBeanProcessor )
				{
					IBeanProcessor( processor ).addBean( bean );
				}
			}
		}
		
		/**
		 * Handle internal interfaces, like IDispatcherAware and ISwizAware
		 */
		protected function handleSwizInterfaces( obj:ISwizInterface ):void
		{
			if( obj is ISwizAware )
				ISwizAware( obj ).swiz = swiz;
			if( obj is IBeanFactoryAware )
				IBeanFactoryAware( obj ).beanFactory = this;
			if( obj is IDispatcherAware )
				IDispatcherAware( obj ).dispatcher = swiz.dispatcher;
			if( obj is IInitializing )
				IInitializing( obj ).init();
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
				initializeBean( bean );
			}
		}
		
		/**
		 * Injection Event Handler defined on SysMgr
		 */
		protected function injectionEventHandlerSysMgr( event:Event ):void
		{
			// make sure the view is not a descendant of the main dispatcher
			// if its not, it is a popup, so we pass it along for processing
			if( !Sprite( swiz.dispatcher ).contains( DisplayObject( event.target ) ) )
			{
				injectionEventHandler( event );
			}
		}
		
		/**
		 * Remove Event Handler
		 */
		// TODO: this probably needs to be removed or customizable
		protected function removeEventHandler( event:Event ):void
		{
			if( isPotentialInjectionTarget( event.target ) )
			{
				var bean:Bean = createBean( event.target );
				removeBean( bean );
			}
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
			
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type );
			
			return bean;
		}
	}
}
