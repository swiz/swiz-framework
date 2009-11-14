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
		protected function processQueueByNameForBean( bean:Bean ):void
		{
			var beanName:String = bean.name;
			
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
		protected function processQueueByTypeForBean( bean:Bean ):void
		{
			for each ( var queue:AutowireQueue in queueByType )
			{
				if ( bean.source is queue.autowire.host.type )
				{
					addAutowire( queue.bean, queue.autowire );
					queueByType.splice( queueByType.indexOf( queue ), 1 );
				}
			}
		}
		
		/**
		 * Add Autowire
		 */
		protected function addAutowire( bean:Bean, autowire:AutowireMetadataTag ):void
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
		protected function removeAutowire( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			if ( autowireTag.bean != null )
			{
				if ( autowireTag.property != null )
				{
					removeAutowireByProperty( bean, autowireTag );
				}
				else
				{
					removeAutowireByName( bean, autowireTag );
				}
			}
			else
			{
				removeAutowireByType( bean, autowireTag );
			}
		}
		
		/**
		 * Add Autowire By Property
		 */
		protected function addAutowireByProperty( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			var namedBean:Bean = getBeanByName( autowireTag.bean );
			
			if ( namedBean != null )
			{
				bean.source[ autowireTag.host.name ] = namedBean.source[ autowireTag.property ];
				addPropertyBinding( bean.source, autowireTag.host.name, namedBean.source, autowireTag.property );
				
				if ( autowireTag.twoWay )
				{
					addPropertyBinding( namedBean.source, autowireTag.property, bean.source, autowireTag.host.name );
				}
			}
			else
			{
				addToQueueByName( bean, autowireTag );
			}
		}
		
		/**
		 * Remove Autowire By Property
		 */
		protected function removeAutowireByProperty( bean:Bean, autowire:AutowireMetadataTag ):void
		{
			var namedBean:Bean = getBeanByName( autowire.bean );
			
			removePropertyBinding( bean.source, autowire.host.name, namedBean.source, autowire.property );
			
			if ( autowire.twoWay )
			{
				removePropertyBinding( namedBean.source, autowire.property, bean.source, autowire.host.name );
			}
			
			bean.source[ autowire.host.name ] = null;
		}
		
		/**
		 * Add Autowire By Name
		 */
		protected function addAutowireByName( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			var namedBean:Bean = getBeanByName( autowireTag.bean );
			
			if ( namedBean != null )
			{
				bean.source[ autowireTag.host.name ] = namedBean.source;
			}
			else
			{
				addToQueueByName( bean, autowireTag );
			}
		}
		
		/**
		 * Remove Autowire By Name
		 */
		protected function removeAutowireByName( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			bean.source[ autowireTag.host.name ] = null;
		}
		
		/**
		 * Add Autowire By Type
		 */
		protected function addAutowireByType( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			var typedBean:Bean = getBeanByType( autowireTag.host.type );
			
			if ( typedBean )
			{
				bean.source[ autowireTag.host.name ] = typedBean.source;
			}
			else
			{
				addToQueueByType( bean, autowireTag );
			}
		}
		
		/**
		 * Remove Autowire By Type
		 */
		protected function removeAutowireByType( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			bean.source[ autowireTag.host.name ] = null;
		}
		
		/**
		 * Get Bean By Name
		 */
		protected function getBeanByName( name:String ):Bean
		{
			for each ( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Bean = beanProvider.getBeanByName( name );
				
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
		protected function getBeanByType( type:Class ):Bean
		{
			for each ( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Bean = beanProvider.getBeanByType( type );
				
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
		protected function addToQueueByName( bean:Bean, autowire:AutowireMetadataTag ):void
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
		protected function addToQueueByType( bean:Bean, autowire:AutowireMetadataTag ):void
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