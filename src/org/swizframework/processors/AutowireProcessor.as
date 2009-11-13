package org.swizframework.processors
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.swizframework.di.Bean;
	import org.swizframework.ioc.IBeanProvider;
	import org.swizframework.metadata.AutowireMetadataTag;
	import org.swizframework.metadata.AutowireQueue;
	
	/**
	 * Autowire Processor
	 */
	public class AutowireProcessor extends MetadataProcessor implements IBeanProcessor
	{
		
		// ========================================
		// public static constants
		// ========================================
		
		public static const AUTOWIRE:String = "Autowire";
		public static const BEAN:String = "bean";
		public static const PROPERTY:String = "property";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var autowireByProperty:Object = {};
		protected var autowireByName:Object = {};
		protected var autowireByType:Object = {};
		protected var queueByName:Object = {};
		protected var queueByType:Array = [];
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function AutowireProcessor()
		{
			super( AUTOWIRE, AutowireMetadataTag, addAutowire, removeAutowire );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function addBean( bean:Bean ):void
		{
			processQueueByNameForBean( bean );
			processQueueByTypeForBean( bean );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeBean( bean:Bean ):void
		{
			// nothing to do here
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Process Queue By Name For Bean
		 */
		protected function processQueueByNameForBean( bean:Object ):void
		{
			var beanName:String = "";
			
			if ( beanName in queueByName )
			{
				for each ( var queue:AutowireQueue in queueByName[ beanName ] )
				{
					addAutowire( queue.bean, queue.autowire );
				}
				
				delete queueByName[ beanName ];
			}
		}
		
		/**
		 * Process Queue By Type For Bean
		 */
		protected function processQueueByTypeForBean( bean:Object ):void
		{
			for each ( var queue:AutowireQueue in queueByType )
			{
				if ( bean is queue.autowire.host.type )
				{
					addAutowire( queue.bean, queue.autowire );
					queueByType.splice( queueByType.indexOf( queue ), 1 );
				}
			}
		}
		
		/**
		 * Add Autowire
		 */
		protected function addAutowire( bean:Object, autowire:AutowireMetadataTag ):void
		{
			if ( autowire.bean != null )
			{
				if ( autowire.property != null )
				{
					addAutowireByProperty( bean, autowire );
				}
				else
				{
					addAutowireByName( bean, autowire );
				}
			}
			else
			{
				addAutowireByType( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire
		 */
		protected function removeAutowire( bean:Object, autowire:AutowireMetadataTag ):void
		{
			if ( autowire.bean != null )
			{
				if ( autowire.property != null )
				{
					removeAutowireByProperty( bean, autowire );
				}
				else
				{
					removeAutowireByName( bean, autowire );
				}
			}
			else
			{
				removeAutowireByType( bean, autowire );
			}
		}
		
		/**
		 * Add Autowire By Property
		 */
		protected function addAutowireByProperty( bean:Object, autowire:AutowireMetadataTag ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( source )
			{
				bean[ autowire.host.name ] = source[ autowire.property ];
				addPropertyBinding( bean, autowire.host.name, source, autowire.property );
				
				if ( autowire.twoWay )
				{
					addPropertyBinding( source, autowire.property, bean, autowire.host.name );
				}
			}
			else
			{
				addToQueueByName( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire By Property
		 */
		protected function removeAutowireByProperty( bean:Object, autowire:AutowireMetadataTag ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( autowire.twoWay )
			{
				removePropertyBinding( source, autowire.property, bean, autowire.host.name );
			}
			
			removePropertyBinding( bean, autowire.host.name, source, autowire.property );
			bean[ autowire.host.name ] = null;
		}
		
		/**
		 * Add Autowire By Name
		 */
		protected function addAutowireByName( bean:Object, autowire:AutowireMetadataTag ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( source )
			{
				bean[ autowire.host.name ] = source;
			}
			else
			{
				addToQueueByName( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire By Name
		 */
		protected function removeAutowireByName( bean:Object, autowire:AutowireMetadataTag ):void
		{
			bean[ autowire.host.name ] = null;
		}
		
		/**
		 * Add Autowire By Type
		 */
		protected function addAutowireByType( bean:Object, autowire:AutowireMetadataTag ):void
		{
			var source:Object = getBeanByType( autowire.host.type );
			
			if ( source )
			{
				Bean( bean ).source[ autowire.host.name ] = source;
			}
			else
			{
				addToQueueByType( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire By Type
		 */
		protected function removeAutowireByType( bean:Object, autowire:AutowireMetadataTag ):void
		{
			bean[ autowire.host.name ] = null;
		}
		
		/**
		 * Get Bean By Name
		 */
		protected function getBeanByName( name:String ):Object
		{
			for each ( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Object = beanProvider.getBeanByName( name );
				
				if ( foundBean != null )
				{
					return foundBean;
				}
			}
			
			return null;
		}
		
		/**
		 * Get Bean By Type
		 */
		protected function getBeanByType( type:Class ):Object
		{
			for each ( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Object = beanProvider.getBeanByType( type );
				
				if ( foundBean != null )
				{
					return foundBean;
				}
			}
			
			return null;
		}
		
		/**
		 * Add To Queue By Name
		 */
		protected function addToQueueByName( bean:Object, autowire:AutowireMetadataTag ):void
		{
			if ( autowire.bean in queueByName )
			{
				queueByName[ autowire.bean ].push( new AutowireQueue( bean, autowire ) );
			}
			else
			{
				queueByName[ autowire.bean ] = [ new AutowireQueue( bean, autowire ) ];
			}
		}
		
		/**
		 * Add To Queue By Type
		 */
		protected function addToQueueByType( bean:Object, autowire:AutowireMetadataTag ):void
		{
			queueByType[ queueByType.length ] = new AutowireQueue( bean, autowire );
		}
		
		/**
		 * Add Property Binding
		 */
		protected function addPropertyBinding( target:Object, targetKey:String, source:Object, sourceKey:String ):void
		{
			var id:String = target + targetKey + source + sourceKey;
			
			autowireByProperty[ id ] = BindingUtils.bindProperty( target, targetKey, source, sourceKey );
		}
		
		/**
		 * Remove Property Binding
		 */
		protected function removePropertyBinding( target:Object, targetKey:String, source:Object, sourceKey:String ):void
		{
			var id:String = target + targetKey + source + sourceKey;
			
			ChangeWatcher( autowireByProperty[ id ] ).unwatch();				
			delete autowireByProperty[ id ];
		}
		
	}
}