package org.swizframework.processors
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.swizframework.di.Bean;
	import org.swizframework.ioc.IBeanProvider;
	import org.swizframework.metadata.AutowireMetadataTag;
	import org.swizframework.metadata.AutowireQueue;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	
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
		protected function addAutowire( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			if ( autowireTag.bean != null )
			{
				if ( autowireTag.property != null )
				{
					addAutowireByProperty( bean, autowireTag );
				}
				else
				{
					addAutowireByName( bean, autowireTag );
				}
			}
			else
			{
				addAutowireByType( bean, autowireTag );
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
		 * 
		 */
		protected function getSourceObject( bean:Bean, autowireTag:AutowireMetadataTag ):Object
		{
			var sourceObject:Object = bean.source;
			var sourcePropertyName:String = autowireTag.property;
			
			if( sourcePropertyName.indexOf( "." ) > -1 )
			{
				// property attribute is a dot path to a nested property
				var arr:Array = sourcePropertyName.split( "." );
				while( arr.length > 1 )
				{
					sourceObject = sourceObject[ arr.shift() ];
				}
			}
			
			return sourceObject;
		}
		
		/**
		 * 
		 */
		protected function getDestinationObject( bean:Bean, autowireTag:AutowireMetadataTag ):Object
		{
			if( autowireTag.destination == null )
			{
				return bean.source;
			}
			else
			{
				var arr:Array = autowireTag.destination.split( "." );
				var dest:Object = bean.source;
				while( arr.length > 1 ) dest = dest[ arr.shift() ];
				return dest;
			}
		}
		
		/**
		 * 
		 */
		protected function getDestinationPropertyName( autowireTag:AutowireMetadataTag ):String
		{
			if( autowireTag.destination == null )
			{
				return autowireTag.host.name;
			}
			else
			{
				var propName:String = autowireTag.destination;
				return ( propName.indexOf( "." ) > -1 ) ? propName.substr( propName.lastIndexOf( "." ) + 1 ) : propName;
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
				var sourceObject:Object = getSourceObject( namedBean, autowireTag );
				var sourcePropertyName:String = autowireTag.property.split( "." ).pop();
				
				var destObject:Object = getDestinationObject( bean, autowireTag );
				var destPropName:String = getDestinationPropertyName( autowireTag );
				
				destObject[ destPropName ] = sourceObject[ sourcePropertyName ];
				
				addPropertyBinding( destObject, destPropName, sourceObject, sourcePropertyName );
				
				if ( autowireTag.twoWay )
				{
					addPropertyBinding( sourceObject, sourcePropertyName, destObject, destPropName );
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
			// TODO: update for dot path properties
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
				var destObject:Object = getDestinationObject( bean, autowireTag );
				var destPropName:String = getDestinationPropertyName( autowireTag );
				
				destObject[ destPropName ] = namedBean.source;
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
			var destObject:Object = getDestinationObject( bean, autowireTag );
			var destPropName:String = getDestinationPropertyName( autowireTag );
			
			destObject[ destPropName ] = null;
		}
		
		/**
		 * Add Autowire By Type
		 */
		protected function addAutowireByType( bean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			// TODO: support injection into multi-param methods
			var setterInjection:Boolean = autowireTag.host is MetadataHostMethod;
			var targetType:Class = ( setterInjection ) ? MethodParameter( MetadataHostMethod( autowireTag.host ).parameters[ 0 ] ).type : autowireTag.host.type;
			var typedBean:Bean = getBeanByType( targetType );
			
			if ( typedBean )
			{
				var destObject:Object = getDestinationObject( bean, autowireTag );
				var destPropName:String = getDestinationPropertyName( autowireTag );
				
				if( setterInjection )
				{
					var f:Function = destObject[ destPropName ] as Function;
					f.apply( destObject, [ typedBean.source ] );
				}
				else
				{
					destObject[ destPropName ] = typedBean.source;
				}
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
			var destObject:Object = getDestinationObject( bean, autowireTag );
			var destPropName:String = getDestinationPropertyName( autowireTag );
			
			destObject[ destPropName ] = null;
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