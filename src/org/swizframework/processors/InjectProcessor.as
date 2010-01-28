package org.swizframework.processors
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.utils.UIDUtil;

	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.metadata.InjectMetadataTag;
	import org.swizframework.metadata.Injection;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataHostClass;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;

	/**
	 * Inject Processor
	 */
	public class InjectProcessor extends BaseMetadataProcessor implements IBeanProcessor
	{
		// ========================================
		// protected static constants
		// ========================================

		protected static const INJECT:String = "Inject";
		protected static const AUTOWIRE:String = "Autowire";

		// ========================================
		// protected properties
		// ========================================

		protected var injectByProperty:Dictionary = new Dictionary();
		protected var injectByName:Object = {};
		protected var injectByType:Object = {};
		protected var queueByName:Object = {};
		protected var queueByType:Array = [];

		// ========================================
		// public properties
		// ========================================

		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.INJECT;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor
		 */
		public function InjectProcessor()
		{
			super( [ INJECT, AUTOWIRE ], InjectMetadataTag );
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

			if( beanName in queueByName )
			{
				for each( var queue:Injection in queueByName[ beanName ] )
				{
					setUpMetadataTag( queue.injectTag, queue.bean );
				}

				delete queueByName[ beanName ];
			}
		}

		/**
		 * Process Queue By Type For Bean
		 */
		protected function processQueueByTypeForBean( bean:Bean ):void
		{
			for each( var queue:Injection in queueByType )
			{
				if( bean.source is queue.injectTag.host.type )
				{
					setUpMetadataTag( queue.injectTag, queue.bean );
					queueByType.splice( queueByType.indexOf( queue ), 1 );
				}
			}
		}

		/**
		 * Add Inject
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var injectTag:InjectMetadataTag = metadataTag as InjectMetadataTag;

			if( injectTag.source != null )
			{
				if( injectTag.source.indexOf( "." ) > -1 )
				{
					addInjectByProperty( injectTag, bean );
				}
				else
				{
					addInjectByName( injectTag, bean );
				}
			}
			else
			{
				addInjectByType( injectTag, bean );
			}
		}

		/**
		 * Remove Inject
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var injectTag:InjectMetadataTag = metadataTag as InjectMetadataTag;

			if( injectTag.source != null )
			{
				if( injectTag.source.indexOf( "." ) > -1 )
				{
					removeInjectByProperty( injectTag, bean );
				}
				else
				{
					removeInjectByName( injectTag, bean );
				}
			}
			else
			{
				removeInjectByType( injectTag, bean );
			}
		}

		/**
		 *
		 */
		protected function getDestinationObject( injectTag:InjectMetadataTag, bean:Bean ):Object
		{
			if( injectTag.destination == null )
			{
				return bean.source;
			}
			else
			{
				var arr:Array = injectTag.destination.split( "." );
				var dest:Object = bean.source;
				while( arr.length > 1 )
					dest = dest[ arr.shift() ];
				return dest;
			}
		}

		/**
		 *
		 */
		protected function getDestinationPropertyName( injectTag:InjectMetadataTag ):String
		{
			if( injectTag.destination == null )
			{
				return injectTag.host.name;
			}
			else
			{
				return injectTag.destination.split( "." ).pop();
			}
		}

		/**
		 * Add Inject By Property
		 */
		protected function addInjectByProperty( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( injectTag.source.split( "." )[ 0 ] );

			if( namedBean != null )
			{
				addPropertyBinding( bean, namedBean, injectTag );
			}
			else
			{
				addToQueueByName( injectTag, bean );
			}
		}

		/**
		 * Remove Inject By Property
		 */
		protected function removeInjectByProperty( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( injectTag.source.split( "." )[ 0 ] );

			removePropertyBinding( bean, namedBean, injectTag );

			if( injectTag.twoWay )
			{
				removePropertyBinding( namedBean, bean, injectTag );
			}

			setDestinationValue( injectTag, bean,  null );
		}

		/**
		 * Add Inject By Name
		 */
		protected function addInjectByName( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var namedBean:Bean = getBeanByName( injectTag.source.split( "." )[ 0 ] );

			if( namedBean != null )
			{
				setDestinationValue( injectTag, bean, namedBean.source );
			}
			else
			{
				addToQueueByName( injectTag, bean );
			}
		}

		/**
		 * Remove Inject By Name
		 */
		protected function removeInjectByName( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			setDestinationValue( injectTag, bean, null );
		}

		/**
		 * Add Inject By Type
		 */
		protected function addInjectByType( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			var setterInjection:Boolean = injectTag.host is MetadataHostMethod;
			var targetType:Class = ( setterInjection ) ? MethodParameter( MetadataHostMethod( injectTag.host ).parameters[ 0 ] ).type : injectTag.host.type;
			if( targetType == null && injectTag.host is MetadataHostClass )
				targetType = getDefinitionByName( injectTag.host.name ) as Class;
			var typedBean:Bean = getBeanByType( targetType );

			if( typedBean )
			{
				setDestinationValue( injectTag, bean, typedBean.source );
			}
			else
			{
				addToQueueByType( injectTag, bean );
			}
		}

		/**
		 * Remove Inject By Type
		 */
		protected function removeInjectByType( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			setDestinationValue( injectTag, bean, null );
		}

		/**
		 * Set Destination Value
		 */
		protected function setDestinationValue( injectTag:InjectMetadataTag, bean:Bean, value:* ):void
		{
			var setterInjection:Boolean = injectTag.host is MetadataHostMethod;

			var destObject:Object = getDestinationObject( injectTag, bean );
			var destPropName:String = getDestinationPropertyName( injectTag );

			if( setterInjection )
			{
				var f:Function = destObject[ destPropName ] as Function;
				f.apply( destObject, [ value ] );
			}
			else
			{
				destObject[ destPropName ] = value;
			}
		}

		/**
		 * Get Bean By Name
		 */
		protected function getBeanByName( name:String ):Bean
		{
			for each( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Bean = beanProvider.getBeanByName( name );

				if( foundBean != null )
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
			for each( var beanProvider:IBeanProvider in swiz.beanProviders )
			{
				var foundBean:Bean = beanProvider.getBeanByType( type );

				if( foundBean != null )
				{
					return foundBean;
				}
			}

			return null;
		}

		/**
		 * Add To Queue By Name
		 */
		protected function addToQueueByName( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			if( injectTag.source in queueByName )
			{
				queueByName[ injectTag.source ].push( new Injection( injectTag, bean ) );
			}
			else
			{
				queueByName[ injectTag.source ] = [ new Injection( injectTag, bean ) ];
			}
		}

		/**
		 * Add To Queue By Type
		 */
		protected function addToQueueByType( injectTag:InjectMetadataTag, bean:Bean ):void
		{
			queueByType[ queueByType.length ] = new Injection( injectTag, bean );
		}

		/**
		 * Add Property Binding
		 */
		protected function addPropertyBinding( destinationBean:Bean, sourceBean:Bean, injectTag:InjectMetadataTag ):void
		{
			var destObject:Object;
			var destPropName:String;
			var cw:ChangeWatcher;
			var uid:String;

			// base scenario of binding an object or property to a property of a bean

			// this is a view added to the display list or a new bean being processed
			destObject = getDestinationObject( injectTag, destinationBean );
			// name of property that will be bound to a source value
			destPropName = getDestinationPropertyName( injectTag );

			// we have to track any bindings we create so we can unwire them later if need be

			// get the uid of our view/new bean
			uid = UIDUtil.getUID( destinationBean.source );
			// create the binding
			cw = BindingUtils.bindProperty( destObject, destPropName, sourceBean.source, injectTag.source.split( "." ).slice( 1 ) );
			// create an array to store bindings for this object if one does not already exist
			injectByProperty[ uid ] ||= [];
			// store this binding
			injectByProperty[ uid ].push( cw );

			// if twoWay binding was requested we have to do things in reverse
			// meaning the existing bean's property will also be bound to the view/new bean's property
			if( injectTag.twoWay )
			{
				// existing bean is the destination object this time
				destObject = sourceBean.source;
				// TODO: this assumes a dot path exists. fix.
				var arr:Array = injectTag.source.split( "." ).slice( 1 );
				// walk the object chain to reach the actual destination object
				while( arr.length > 1 )
					destObject = destObject[ arr.shift() ];
				// the last token of the source attribute is the actual property name
				destPropName = injectTag.source.split( "." ).pop();

				// create the reverse binding where the view/new bean is the source
				// TODO: store this binding too
				if( injectTag.destination != null )
				{
					// if a destination was provided we can use it as the host chain value
					BindingUtils.bindProperty( destObject, destPropName, destinationBean.source, injectTag.destination.split( "." ) );
				}
				else
				{
					// if no destination was provided we use the name of the decorated property as the host chain value
					BindingUtils.bindProperty( destObject, destPropName, destinationBean.source, injectTag.host.name );
				}
			}
		}

		/**
		 * Remove Property Binding
		 */
		protected function removePropertyBinding( destination:Bean, source:Bean, injectTag:InjectMetadataTag ):void
		{
			var uid:String = UIDUtil.getUID( destination.source );
			for each( var cw:ChangeWatcher in injectByProperty[ uid ] )
			{
				cw.unwatch();
			}
			delete injectByProperty[ uid ];
		}
	}
}