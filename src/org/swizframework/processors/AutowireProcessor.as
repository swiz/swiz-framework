package org.swizframework.processors
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.utils.UIDUtil;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.metadata.AutowireMetadataTag;
	import org.swizframework.metadata.AutowireQueue;
	import org.swizframework.reflection.MetadataHostClass;
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
		
		protected var autowireByProperty:Dictionary = new Dictionary();
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
					addAutowire( queue.autowireTag, queue.bean );
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
				if ( bean.source is queue.autowireTag.host.type )
				{
					addAutowire( queue.autowireTag, queue.bean );
					queueByType.splice( queueByType.indexOf( queue ), 1 );
				}
			}
		}
		
		/**
		 * Add Autowire
		 */
		protected function addAutowire( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			if ( autowireTag.source != null )
			{
				if ( autowireTag.source.indexOf( "." ) > -1 )
				{
					addAutowireByProperty( autowireTag, bean );
				}
				else
				{
					addAutowireByName( autowireTag, bean );
				}
			}
			else
			{
				addAutowireByType( autowireTag, bean );
			}
		}
		
		/**
		 * Remove Autowire
		 */
		protected function removeAutowire( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			if ( autowireTag.source != null )
			{
				if ( autowireTag.source.indexOf( "." ) > -1 )
				{
					removeAutowireByProperty( autowireTag, bean );
				}
				else
				{
					removeAutowireByName( autowireTag, bean );
				}
			}
			else
			{
				removeAutowireByType( autowireTag, bean );
			}
		}
		
		/**
		 * 
		 */
		protected function getDestinationObject( autowireTag:AutowireMetadataTag, bean:Bean ):Object
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
				return autowireTag.destination.split( "." ).pop();
			}
		}
		
		/**
		 * Add Autowire By Property
		 */
		protected function addAutowireByProperty( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( autowireTag.source.split( "." )[ 0 ] );
			
			if ( namedBean != null )
			{
				addPropertyBinding( bean, namedBean, autowireTag );
			}
			else
			{
				addToQueueByName( autowireTag, bean );
			}
		}
		
		/**
		 * Remove Autowire By Property
		 */
		protected function removeAutowireByProperty( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			// TODO: update for dot path properties
			var namedBean:Bean = getBeanByName( autowireTag.source );
			
			removePropertyBinding( bean, namedBean, autowireTag );
			
			if ( autowireTag.twoWay )
			{
				removePropertyBinding( namedBean, bean, autowireTag );
			}
			
			bean.source[ autowireTag.host.name ] = null;
		}
		
		/**
		 * Add Autowire By Name
		 */
		protected function addAutowireByName( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( autowireTag.source.split( "." )[ 0 ] );
			
			if ( namedBean != null )
			{
				var destObject:Object = getDestinationObject( autowireTag, bean );
				var destPropName:String = getDestinationPropertyName( autowireTag );
				
				destObject[ destPropName ] = namedBean.source;
			}
			else
			{
				addToQueueByName( autowireTag, bean );
			}
		}
		
		/**
		 * Remove Autowire By Name
		 */
		protected function removeAutowireByName( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			var destObject:Object = getDestinationObject( autowireTag, bean );
			var destPropName:String = getDestinationPropertyName( autowireTag );
			
			destObject[ destPropName ] = null;
		}
		
		/**
		 * Add Autowire By Type
		 */
		protected function addAutowireByType( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			// TODO: support injection into multi-param methods
			var setterInjection:Boolean = autowireTag.host is MetadataHostMethod;
			var targetType:Class = ( setterInjection ) ? MethodParameter( MetadataHostMethod( autowireTag.host ).parameters[ 0 ] ).type : autowireTag.host.type;
			if( targetType == null && autowireTag.host is MetadataHostClass )
				targetType = getDefinitionByName( autowireTag.host.name ) as Class;
			var typedBean:Bean = getBeanByType( targetType );
			
			if ( typedBean )
			{
				var destObject:Object = getDestinationObject( autowireTag, bean );
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
				addToQueueByType( autowireTag, bean );
			}
		}
		
		/**
		 * Remove Autowire By Type
		 */
		protected function removeAutowireByType( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			var destObject:Object = getDestinationObject( autowireTag, bean );
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
		protected function addToQueueByName( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			if ( autowireTag.source in queueByName )
			{
				queueByName[ autowireTag.source ].push( new AutowireQueue( autowireTag, bean ) );
			}
			else
			{
				queueByName[ autowireTag.source ] = [ new AutowireQueue( autowireTag, bean ) ];
			}
		}
		
		/**
		 * Add To Queue By Type
		 */
		protected function addToQueueByType( autowireTag:AutowireMetadataTag, bean:Bean ):void
		{
			queueByType[ queueByType.length ] = new AutowireQueue( autowireTag, bean );
		}
		
		/**
		 * Add Property Binding
		 */
		protected function addPropertyBinding( destinationBean:Bean, sourceBean:Bean, autowireTag:AutowireMetadataTag ):void
		{
			var destObject:Object;
			var destPropName:String;
			var cw:ChangeWatcher;
			var uid:String;
			
			// base scenario of binding an object or property to a property of a bean
			
			// this is a view added to the display list or a new bean being processed
			destObject = getDestinationObject( autowireTag, destinationBean );
			// name of property that will be bound to a source value
			destPropName = getDestinationPropertyName( autowireTag );
			
			// we have to track any bindings we create so we can unwire them later if need be
			
			// get the uid of our view/new bean
			uid = UIDUtil.getUID( destinationBean.source );
			// create the binding
			cw = BindingUtils.bindProperty( destObject, destPropName, sourceBean.source, autowireTag.source.split( "." ).slice( 1 ) );
			// create an array to store bindings for this object if one does not already exist
			autowireByProperty[ uid ] ||= [];
			// store this binding
			autowireByProperty[ uid ].push( cw );
			
			// if twoWay binding was requested we have to do things in reverse
			// meaning the existing bean's property will also be bound to the view/new bean's property
			if( autowireTag.twoWay )
			{
				// existing bean is the destination object this time
				destObject = sourceBean.source;
				// TODO: this assumes a dot path exists. fix.
				var arr:Array = autowireTag.source.split( "." ).slice( 1 );
				// walk the object chain to reach the actual destination object
				while( arr.length > 1 ) destObject = destObject[ arr.shift() ];
				// the last token of the source attribute is the actual property name
				destPropName = autowireTag.source.split( "." ).pop();
				
				// create the reverse binding where the view/new bean is the source
				// TODO: store this binding too
				if( autowireTag.destination != null )
				{
					// if a destination was provided we can use it as the host chain value
					BindingUtils.bindProperty( destObject, destPropName, destinationBean.source, autowireTag.destination.split( "." ) );
				}
				else
				{
					// if no destination was provided we use the name of the decorated property as the host chain value
					BindingUtils.bindProperty( destObject, destPropName, destinationBean.source, autowireTag.host.name );
				}
			}
		}
		
		/**
		 * Remove Property Binding
		 */
		protected function removePropertyBinding( destination:Bean, source:Bean, autowireTag:AutowireMetadataTag ):void
		{
			var uid:String = UIDUtil.getUID( destination.source );
			for each( var cw:ChangeWatcher in autowireByProperty[ uid ] )
			{
				cw.unwatch();
			}
			delete autowireByProperty[ uid ];
		}
		
	}
}