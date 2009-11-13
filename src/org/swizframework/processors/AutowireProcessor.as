package org.swizframework.processors
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.swizframework.ioc.IBeanProvider;
	import org.swizframework.metadata.AutowireMetadata;
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
			super( AUTOWIRE, AutowireMetadata, addAutowire, removeAutowire );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function addBean( bean:Object ):void
		{
			processQueueByNameForBean( bean );
			processQueueByTypeForBean( bean );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeBean( bean:Object ):void
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
				if ( bean is queue.autowire.targetType )
				{
					addAutowire( queue.bean, queue.autowire );
					queueByType.splice( queueByType.indexOf( queue ), 1 );
				}
			}
		}
		
		/**
		 * Add Autowire
		 */
		protected function addAutowire( bean:Object, autowire:AutowireMetadata ):void
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
		protected function removeAutowire( bean:Object, autowire:AutowireMetadata ):void
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
		protected function addAutowireByProperty( bean:Object, autowire:AutowireMetadata ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( source )
			{
				bean[ autowire.targetName ] = source[ autowire.property ];
				addPropertyBinding( bean, autowire.targetName, source, autowire.property );
				
				if ( autowire.twoWay )
				{
					addPropertyBinding( source, autowire.property, bean, autowire.targetName );
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
		protected function removeAutowireByProperty( bean:Object, autowire:AutowireMetadata ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( autowire.twoWay )
			{
				removePropertyBinding( source, autowire.property, bean, autowire.targetName );
			}
			
			removePropertyBinding( bean, autowire.targetName, source, autowire.property );
			bean[ autowire.targetName ] = null;
		}
		
		/**
		 * Add Autowire By Name
		 */
		protected function addAutowireByName( bean:Object, autowire:AutowireMetadata ):void
		{
			var source:Object = getBeanByName( autowire.bean );
			
			if ( source )
			{
				bean[ autowire.targetName ] = source;
			}
			else
			{
				addToQueueByName( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire By Name
		 */
		protected function removeAutowireByName( bean:Object, autowire:AutowireMetadata ):void
		{
			bean[ autowire.targetName ] = null;
		}
		
		/**
		 * Add Autowire By Type
		 */
		protected function addAutowireByType( bean:Object, autowire:AutowireMetadata ):void
		{
			var source:Object = getBeanByType( autowire.targetType );
			
			if ( source )
			{
				bean[ autowire.targetName ] = source;
			}
			else
			{
				addToQueueByType( bean, autowire );
			}
		}
		
		/**
		 * Remove Autowire By Type
		 */
		protected function removeAutowireByType( bean:Object, autowire:AutowireMetadata ):void
		{
			bean[ autowire.targetName ] = null;
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
		protected function addToQueueByName( bean:Object, autowire:AutowireMetadata ):void
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
		protected function addToQueueByType( bean:Object, autowire:AutowireMetadata ):void
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