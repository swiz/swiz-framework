package org.swizframework.factory
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.utils.DescribeTypeCache;
	import mx.utils.DescribeTypeCacheRecord;
	import mx.utils.UIDUtil;
	
	import org.swizframework.Swiz;
	import org.swizframework.events.DynamicMediator;
	import org.swizframework.util.BeanLoader;
	import org.swizframework.util.ExpressionUtils;
	import org.swizframework.util.MediatorUtil;
	
	public class BeanFactory
	{
		
		private static const logger:ILogger = Log.getLogger("BeanFactory");
		
		/** Dictionary, references to all beans */
		private var _beans : Dictionary;
		
		/** Dictionary, registry of all events */
		private var _allEventDispatchers : Dictionary;
		
		/** Dictionary, references to all mediators */
		private var _allMediators : Dictionary;
		
		private var _viewTypeMediators : Dictionary = new Dictionary();
		private var _mediatedViewInstances : Dictionary = new Dictionary();
		
		// stores property bindings from Autowire tags with property attribute
		private var beanBindings : Dictionary = new Dictionary();
		
		public function BeanFactory()
		{
			_beans = new Dictionary();
			_allEventDispatchers = new Dictionary();
			_allMediators = new Dictionary();
		}
		
		/** 
		 * creates any supplied BeanLoaders and retrieves their beans to add 
		 * to the local cache and autowire them. 
		 */
		public function loadBeans( beanLoaders : Array ) : void {
			
			var classRef : Class;
			var loader : BeanLoader;
			var dict : Dictionary;
			var bean : Object;
			var beans:Array = [];
			var initBeans:Array = [];
			var metadataAwareBeans:Array = [];
			
			// instanciate each loaders
			for (var i : int = 0; i<beanLoaders.length; i++) {
				if(Swiz.hasLogLevel(LogEventLevel.INFO))
					logger.info("loading beanloader: "+i);
				
				classRef = beanLoaders[i];
				loader = new classRef();
				
				// and add each bean
				dict = loader.getBeans();
				for (var key : String in dict) {
					bean = dict[key];
					addBean(key, bean);
					beans.push(bean);
					// if it's an initializing bean, add to array
					if (bean is IInitializingBean)
						initBeans.push(bean);
					if (bean is IMetadataAwareBean)
						metadataAwareBeans.push(bean);
					if (bean is IDispatcherBean)
						IDispatcherBean(bean).dispatcher = Swiz.systemManager;
				}
			}
			
			// now autowire all the new beans
			for each( var newbean : Object in beans ) {
				var beanDesc:XML = autowire(newbean);
				
				
				// when there are metadataAwareBeans let's check
				// if the newbean contains a metadata any metadataAwareBean is interested in
				if(metadataAwareBeans.length > 0)
				{
					for each(var metadataAwareBean:IMetadataAwareBean in metadataAwareBeans)
					{
						var annotations:Array = metadataAwareBean.getInterestedMetadata();
						for each(var anno:String in annotations)
						{
							// check accessors
							if(beanDesc.accessor.metadata.(@name == anno).length() > 0)
							{
								metadataAwareBean.processMetadata(beanDesc, newbean);
							}
						}
					}
				}
			}
			
			// now call initialize on all the initializing beans
			for each( var initBean : Object in initBeans) {
				IInitializingBean(initBean).initialize();
			}
		}
		
		/** Adds a bean by id to the bean cache */
		public function addBean( beanId : String, bean : Object ) : void {
			// if bean is DynamicChannelSet, create the Channel, maybe add init method...
			// if ( bean is DynamicChannelSet ) {
				// DynamicChannelSet(bean).createChannel();
			// }
			_beans[ beanId ] = bean;
		}
		
		/** Get bean returns any Swiz managed bean */
		public function getBean( beanId : String ) : Object {
			if (_beans[ beanId ] != null) {
				if (_beans[ beanId ] is IFactoryBean)
					return IFactoryBean(_beans[ beanId ]).getObject();
				else
					return _beans[ beanId ];
			} else {
				throw new Error( "Bean named " + beanId + " is not defined for this application.");
			}
		}
		
		/** Looks for any bean matching the required type. Returns an array of found beans */
		public function getBeanByType( type : String ) : Array {
			// loop over all the beans, return array of any matching the type
			var found : Array = new Array();
			var beanDesc : XML;
			
			for each( var bean : Object in _beans ) {
				// get the bean description, retrieve from Factory if necessary;
				if (bean is IFactoryBean)
					beanDesc = IFactoryBean(bean).getObjectDescription();
				else
					beanDesc = getBeanDescription(bean);
				
				// we're looking for the any class, or super class, or interface matching the requested type
				var isClass:Boolean = beanDesc.@name == type || beanDesc.@type == type;
				var isBaseClass:Boolean = (beanDesc.extendsClass.(@type == type) as XMLList).length() > 0;
				var isInterface:Boolean = (beanDesc.implementsInterface.(@type == type) as XMLList).length() > 0;
				
				if (isClass || isBaseClass || isInterface) {
					found.push(bean);
				}
			}
			
			return found;
		}
		
		/** Returns true if a bean exists in the cache for the supplied id */
		public function containsBean( beanId : String ) : Boolean {
			return _beans[beanId] != null;
		}
		
		/** Inspects a bean object to autowire all fields, and create mediators */
		public function autowire( obj : Object ) : XML {
			
			// retrieve bean description
			var beanDesc : XML = getBeanDescription( obj );
			
			var variables : XMLList = beanDesc.variable;
			var accessors : XMLList = beanDesc.accessor.( @access == "readwrite" || @access == "writeonly" );
			var events : XMLList = beanDesc.metadata.(@name == "Event");
			var mediatedMethods : XMLList = beanDesc.method.(children().(attribute("name") == "Mediate").length() > 0);
			
			// loop over each variable xml item, checking for 'Autowire' metadata...
			resolveDependencies(obj, variables);
			// now the same for the accessors
			resolveDependencies(obj, accessors);
			
			// and register any mediators for methods
			resolveMediators(obj, mediatedMethods);
			
			var className : String = beanDesc.@name.split( "::" ).join( "." );
			var mediateVew : Boolean = false;
			// add an empty string in order to support full class name in mediate tag
			// even if viewPackages was not set (will be removed after this loop)
			Swiz.getInstance().getViewPackages().push( "" );
			
			for( var viewType : String in _viewTypeMediators )
			{
				for each( var viewPkg : String in Swiz.getInstance().getViewPackages() )
				{
					// build full name by combining viewPackage from SwizConfig and  value of view attribute in [Mediate]
					var qName : String = ( viewPkg != "" ) ? viewPkg + "." + viewType : viewType;
					// convert in case they used :: format
					qName = qName.split( "::" ).join( "." );
					
					// if we've matched the type of object being added to the stage
					if( qName == className )
					{
						// create a unique id for this view instance so we can remove its listeners
						// if/when it is removed from stage
						var uid:String = UIDUtil.getUID( obj );
						
						// create an array keyed off of uid to hold related mediators
						_mediatedViewInstances[ uid ] = [];
						// iterate over mediators created for this view type
						for each( var mediator:DynamicMediator in _viewTypeMediators[ viewType ] )
						{
							// attach listener to this view instance
							obj.addEventListener( mediator.eventType, mediator.respond, false, 0, true );
							
							// store for later removal (if view is removed from stage)
							_mediatedViewInstances[ uid ].push( mediator );
						}
					}
				}
			}
			// remove empty string
			Swiz.getInstance().getViewPackages().pop();
			
			return beanDesc;
		}
		
		/** Removes any method mediators or event dispatchers for an object */
		public function unwire( obj : Object ) : void {
			
			// retrieve bean description
			var beanDesc : XML = getBeanDescription(obj);
			var events : XMLList = beanDesc.metadata.(@name == "Event");
			var mediatedMethods : XMLList = beanDesc.method.(children().(attribute("name") == "Mediate").length() > 0);
			
			removeMediators(obj, mediatedMethods);
			
			// if we've added any mediator event listeners to this view instance remove them
			var uid:String = UIDUtil.getUID( obj );
			var instanceMediators : Array = _mediatedViewInstances[ uid ];
			
			// delete any property bindings we have created
			var bindings : Array = beanBindings[ uid ];
			if( bindings != null )
			{
				for each( var cw:ChangeWatcher in bindings )
				{
					cw.unwatch();
				}
				bindings = null;
				delete beanBindings[ uid ];
			}
			
			if( instanceMediators != null && instanceMediators.length > 0 )
			{
				// iterate over mediators created for this view type
				for each( var mediator:DynamicMediator in instanceMediators )
				{
					// remove listener from this view instance
					obj.removeEventListener( mediator.eventType, mediator.respond );
				}
				instanceMediators.splice( 0 );
				delete _mediatedViewInstances[ uid ];
			}
		}
		
		public static function getBeanDescription( obj : * ) : XML {
			// wrapping the describe type in try / catch so primitive type beans will not fail
			var beanDesc : XML;
			try {
				var cacheDescription : DescribeTypeCacheRecord = DescribeTypeCache.describeType( obj );
				beanDesc = cacheDescription.typeDescription;
			} catch ( e : ReferenceError ) {
				beanDesc = describeType( obj );
			}
			return beanDesc;
		}
		
		private function resolveDependencies( obj : Object, accessorList : XMLList ) : void {
			for each (var depends : XML in accessorList) {
				
				var isAutowireView:Boolean = false;
				
				if (depends.metadata != undefined && depends.metadata.( @name== "Autowire" ).length() > 0) {
					var meta : XML = depends.metadata.( @name == "Autowire" )[ 0 ];
					var propertyName : String = depends.@name;
					var propertyType : String = depends.@type;
					var foundBean : *;
					var beanPropName:String = ( metadataArgProvided( meta, "property" ) ) ? getMetadataArgValue( meta, "property" ) : "";
					
					if ( metadataArgProvided( meta, "bean" ) ) {
						// autowire by name
						var dependencyName : String = meta.arg.( @key == "bean" ).@value;
						if ( _beans[ dependencyName ] != null ) {
							foundBean = _beans[ dependencyName ];
						}
					// check for Autowire view and if exists store in Swiz dict for later injection on added_to_stage
					} else if(meta.arg.( @key == "view" ) != null && meta.arg.( @key == "view" ).@value == "true") {
						isAutowireView = true;
						var memberName:String = depends.@name;
						var memberType:String = depends.@type;
						var dict:Dictionary = Swiz.getInstance().autowiredViews;
						if(dict == null)
						{
							dict = new Dictionary(true);
							Swiz.getInstance().autowiredViews = dict;
						}
						
						dict[memberType] ||= [];
						dict[memberType].push({target:obj,property:memberName});
					} else {
						// autowire by type
						if(Swiz.hasLogLevel(LogEventLevel.INFO))
							logger.info("attempting autowire {0} by type...", propertyName);
						var candidates : Array = getBeanByType(propertyType);
						if (candidates.length == 1) {
							foundBean = candidates[0];
						} else if (candidates.length > 0) {
							throw new Error("AmbiguousReferenceError. More than one bean was found with type: "+propertyType);
						} 
					}
					// if we found a bean, set the property on the object, look for factory beans here
					if (!isAutowireView && foundBean == null && Swiz.hasLogLevel(LogEventLevel.WARN))
						logger.warn("No bean was found with id: {0}, cannot autowire property!", dependencyName);
					else if (!isAutowireView && foundBean is IFactoryBean)
						obj[ propertyName ] = IFactoryBean(foundBean).getObject();
					else if (!isAutowireView && beanPropName != "")
					{
						// if a specific property is being wired, make sure the bean has the property requested
						if( foundBean.hasOwnProperty( beanPropName ) )
						{
							// simple types need a bit more help
							var beanPropBindable : XML = DescribeTypeCache.describeType( foundBean ).typeDescription.accessor.( @name == beanPropName ).metadata.( @name == "Bindable" )[ 0 ];
							var destPropBindable : XML = DescribeTypeCache.describeType( obj ).typeDescription.accessor.( @name == propertyName ).metadata.( @name == "Bindable" )[ 0 ];
							// if the property on both the bean and the target are bindable, we set up a binding
							if( beanPropBindable != null && destPropBindable != null )
							{
								// bind the target property to the bean's property
								var uid : String = UIDUtil.getUID( obj );
								// make sure we have an array of bindings for this destination object
								beanBindings[ uid ] ||= [];
								// store the ChangeWatcher that represents this binding
								beanBindings[ uid ].push( BindingUtils.bindProperty( obj, propertyName, foundBean, beanPropName ) );
								// if twoWay binding was requested we bind the bean to the target as well
								if( getMetadataArgValue( meta, "twoWay" ) == "true" )
								{
									// create and store reverse binding
									beanBindings[ uid ].push( BindingUtils.bindProperty( foundBean, beanPropName, obj, propertyName ) );
								}
							}
							else
							{
								// if either of the properties is not bindable we do a simple assignment
								obj[ propertyName ] = foundBean[ beanPropName ];
							}
						}
						else
						{
							throw new Error( "ReferenceError: Property " + beanPropName + " not found on " + getQualifiedClassName( foundBean ).split(/\:\:/)[ 1 ] );
						}
					}
					else if (!isAutowireView)
						obj[ propertyName ] = foundBean;
				}
			}
		}
		
		private function resolveMediators( obj : Object, methodList : XMLList ) : void {
			for each (var method : XML in methodList) {
				var metadatas : XMLList = method.metadata.(@name == "Mediate");
				var methodName : String = method.@name;
				
				for each (var meta : XML in metadatas) {
					if ( metadataArgProvided( meta, "event" ) ) {
						var eventName : String = getMetadataArgValue( meta, "event" );
						// if the event name is an expression, we need to resolve it
						var resolvedName : String;
						if (eventName.substr(0,2) == "${") {
							resolvedName = ExpressionUtils.evaluate(eventName);
							if (eventName == null)
								throw new Error("Exception evaluating Expression: "+eventName);
							else
								eventName = resolvedName;
						}
						
						var eventProperties : String = null;
						if ( metadataArgProvided( meta, "properties" ) ) {
							// get string from xml, replace spaces with empty strings
						 	eventProperties = String( meta.arg.( @key == "properties" ).@value ).split( " " ).join( "" );
						}
						
						if(Swiz.isStrict()) {
							eventName = MediatorUtil.validateEvent( eventName, eventProperties );
							if( eventName != null )
							{
								addMethodMediators( obj, methodName, eventName, eventProperties, meta );
							}
						} else {
							addMethodMediators( obj, methodName, eventName, eventProperties, meta );
						}
					}
				}
			}
		}
				
		private function removeMediators( obj : Object, methodList : XMLList ) : void {
			for each (var method : XML in methodList) {
				var metadatas : XMLList = method.metadata.(@name == "Mediate");
				var methodName : String = method.@name;
				
				for each (var meta : XML in metadatas) {
					if (metadataArgProvided( meta, "event" )) {
						var eventName : String = meta.arg.(@key == "event").@value;
						// removeMethodMediators(eventName, obj[methodName]);
						removeMethodMediators(obj, methodName, eventName);
					}
				}
			}
		}
		
		private function getMetadataArgValue( metadata : XML, argName : String ):*
		{
			return metadata.arg.( @key == argName ).@value;
		}
		
		private function metadataArgProvided( metadata : XML, argName : String ):Boolean
		{
			return metadata.arg.( @key == argName ) != null && metadata.arg.( @key == argName ).@value != undefined;
		}
		
		private function addMethodMediators( obj : Object, methodName : String, eventName : String, eventProperties : String, metadata : XML = null ) : void {
			
			// make sure _alMediators has a dictionary for this event type
			_allMediators[eventName] ||= new Dictionary();
			var eventMediators : Dictionary = _allMediators[eventName] as Dictionary;
			
			// now make sure we have a dictionary below this event name for this object
			eventMediators[obj] ||= new Dictionary();
			
			var objMediators : Dictionary = eventMediators[obj];
			
			if (!objMediators[methodName]) {
				if(Swiz.hasLogLevel(LogEventLevel.INFO))
					logger.info("creating mediator for: {0} for {1}", eventName, methodName);
				var mediator : DynamicMediator = new DynamicMediator(obj[methodName], eventProperties, eventName);
				mediator.stopPropagation = getMetadataArgValue( metadata, "stopPropagation" ) == "true";
				mediator.stopImmediatePropagation = getMetadataArgValue( metadata, "stopImmediatePropagation" ) == "true";
				
				var priority:int = getMetadataArgValue( metadata, "priority" );
				if(isNaN(priority))
				{
					priority = 0;
				}
				
				// eventMediators[key] = mediator;
				objMediators[methodName] = mediator;
				
				// if we're supporting bubbled events add a listener to the app root
				if( Swiz.bubbledEventsMediated() )
				{
					Swiz.systemManager.addEventListener( eventName, mediator.respond, false, priority );
				}
				
				// if a view type was specified in Mediate tag register it
				// event listener will be created in autowire() when an instance of view type is added to stage
				if( metadataArgProvided( metadata, "view" ) )
				{
					var viewName : String = getMetadataArgValue( metadata, "view" );
					_viewTypeMediators[ viewName ] ||= [];
					_viewTypeMediators[ viewName ].push( mediator );
				}
				else
				{
					Swiz.addEventListener( eventName, mediator.respond, false, priority );
				}
				
			} else if(Swiz.hasLogLevel(LogEventLevel.WARN)){
				logger.warn("Mediator already exists for {0}", methodName);
			}
		}
		
		private function removeMethodMediators(obj : Object, methodName : String, eventName : String) : void {
			
			if (_allMediators[eventName] && _allMediators[eventName][obj]) {
				// Remove the swiz listener for each mediator.
				for each (var mediator : DynamicMediator in _allMediators[eventName][obj]) {
					Swiz.removeEventListener(eventName, mediator.respond);
				}
				
				// Remove the dispatcher listeners from each mediator.
				for each (var dispatcher : IEventDispatcher in _allEventDispatchers[eventName]) {
					dispatcher.removeEventListener(eventName, mediator.respond);
				}

				delete _allMediators[eventName][obj];
			}
		}

	}
}