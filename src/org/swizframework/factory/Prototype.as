package org.swizframework.factory {
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.utils.UIDUtil;
	
	import org.swizframework.Swiz;
	
	public class Prototype implements IFactoryBean {
		private static const logger : ILogger = Log.getLogger( "Prototype" );
		
		private var beanId : String;
		private var beanInstance : *;
		private var beanDescription : XML;
		
		public var className : String;
		public var classReference : Class;
		public var constructorArguments : *;
		
		[Inspectable( defaultValue=false )]
		public var singleton : Boolean = false;
		
		public function Prototype() {
		}
		
		public function getObject() : * {
			
			// for singletons, we'll keep the instance cached locally
			var instance : Object = beanInstance;
			
			// make sure we have an instanceId
			if ( beanId == null ) {
				beanId = UIDUtil.createUID();
				if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "Creating UID for prototype: {0}", beanId );
			}
			
			// if this prototype is set as a singleton, we need to look for an instance in Swiz's cache
			if ( singleton ) {
				
				if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "Prototype set to singleton, return cached bean if we have it" );
				// if we haven't yet, create instance and cache it
				if ( instance == null ) {
					beanInstance = createInstance();
					instance = beanInstance;
					// Swiz.addBean(beanId, instance);
					Swiz.autowire( instance );
					// if it's an initializing bean, call initialize
					if ( instance is IInitializingBean )
						IInitializingBean( instance ).initialize();
				}
			} else {
				if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "Prototype set to non-singleton..." );
				
				if ( instance == null ) {
					
					// create and store bean instance, remove it after autowiring
					beanInstance = createInstance();
					instance = beanInstance;
					Swiz.autowire( instance );
					// if it's an initializing bean, call initialize
					if ( instance is IInitializingBean )
						IInitializingBean( instance ).initialize();
					
					// clear beanInstance
					beanInstance = null;
				}
			}
			
			return instance;
		}
		
		// format the object type properly to match Flash's type format (returned from describeType)
		public function getObjectType() : String {
			className ||= getQualifiedClassName( classReference );
			var lastDel : int = className.lastIndexOf( "." );
			var classDel : int = className.lastIndexOf( "::" );
			if ( lastDel > -1 && classDel < 0 )
				return className.substr( 0, lastDel ) + "::" + className.substr( lastDel + 1, className.length );
			else
				return className;
		}
		
		public function getObjectDescription() : XML {
			
			if ( beanDescription == null ) {
				var clazz : Class = getClass();
				var beanDesc : XML = describeType( clazz );
				if ( beanDesc.factory != undefined && beanDesc.factory.length() > 0 ) {
					beanDesc =  beanDesc.factory[0];
				}
				beanDescription = beanDesc;
			}
			
			// wrapping the describe type in try / catch so primitive type beans will not fail
			/* var clazz : Class = getClass();
			   var beanDesc : XML;
			   try {
			   var cacheDescription : DescribeTypeCacheRecord = DescribeTypeCache.describeType( clazz );
			   beanDesc = cacheDescription.typeDescription;
			   } catch ( e : ReferenceError ) {
			   beanDesc = describeType( clazz );
			   }
			   if (beanDesc.factory != undefined && beanDesc.factory.length() > 0) {
			   var nested : XMLList = beanDesc.factory;
			   beanDesc =  nested[0];
			 } */
			return beanDescription;
		}
		
		private function createInstance() : Object {
			if ( className == null && classReference == null )
				throw new Error( "Bean Creation exception! You must supply classReference or className to Prototype!" );
			
			if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "Creating a bean of type: {0}", getObjectType() );
			
			// create a new instance
			var clazz : Class = getClass();
			var instance : *;
			
			if ( constructorArguments != null ) {
				var args:Array = constructorArguments is Array ? constructorArguments : [constructorArguments ];
				
				switch ( args.length ) {
					case 1:
						instance = new clazz( args[ 0 ] );
						break;
					case 2:
						instance = new clazz( args[ 0 ], args[ 1 ] );
						break;
					case 3:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ] );
						break;
					case 4:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ] );
						break;
					case 5:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] );
						break;
					case 6:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ] );
						break;
					case 7:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ] );
						break;
					case 8:
						instance = new clazz( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 7 ], args[ 8 ] );
						break;
				}
			} else {
				instance = new clazz();
			}
			
			return instance;
		}
		
		private function getClass() : Class {
			return classReference != null ? classReference : getDefinitionByName( getObjectType() ) as Class;
		}
	}
}