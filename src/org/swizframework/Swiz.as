package org.swizframework {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.rpc.AsyncToken;
	
	import org.swizframework.events.CentralDispatcher;
	import org.swizframework.factory.BeanFactory;
	import org.swizframework.net.DynamicURLRequest;
	import org.swizframework.rpc.DynamicCommand;
	import org.swizframework.rpc.DynamicResponder;
	
	public class Swiz {
		/**
		 * @return application (Flex 2/3) or topLevelApplication (Flex 4) depending on the flex4 compiler flag
		 */
		public static function get application() : IEventDispatcher {
			if ( CONFIG::flex4 ) {
				return mx.core.FlexGlobals.topLevelApplication as IEventDispatcher;
			}
			return Application.application as IEventDispatcher;
		}
		
		/**
		 * @return systemManager from application (Flex 2/3) or topLevelApplication (Flex 4) depending on the flex4 compiler flag
		 */
		public static function get systemManager() : IEventDispatcher {
			if ( CONFIG::flex4 ) {
				return mx.core.FlexGlobals.topLevelApplication as IEventDispatcher;
			}
			return Application.application.systemManager as IEventDispatcher;
		}
		
		/** Swiz logging instance */
		private static const logger : ILogger = Log.getLogger( "org.swizframework.Swiz" );
		
		/** Swiz singleton instance */
		private static var _applicationFactory : Swiz;
		
		/** Application Controller instance */
		private var _centralDispatcher : CentralDispatcher;
		
		/** Swiz Bean Factory instance */
		private var _beanFactory : BeanFactory;
		
		/** eventPackages for shortening event names in strict mode
		 * like e.g. com.foo.event
		 */
		private var eventPackages : Array = [];
		
		/** viewPackages to restrict dependency injection on
		 * like e.g. com.foo.view
		 */
		private var viewPackages : Array = [];
		
		/**
		 * Map to store autowireView beans
		 * key is view type
		 * value is object with target bean and target property
		 */
		public var autowiredViews : Dictionary = new Dictionary();
		
		/**
		 * application class name used with viewPackages to autowire
		 * the application itself
		 */
		private var _appClassName : String;
		
		/** Core Swiz Events */
		public static const INIT_COMPLETE : String = "eventSwizInitComplete";
		
		/** Dictionary, references to all beans
		 private var _allBeans : Dictionary; */
		
		/** Array, registry of all events
		 private var _allEventDispatchers : Dictionary; */
		
		/** Dictionary, references to all mediators
		 private var _allMediators : Dictionary; */
		
		/** Lock to enforce singleton */
		private static var lock : Boolean = false;
		
		/** strict flag to enable further runtime validation */
		private static var strict : Boolean = false;
		
		/** executeSerciceCall fault handler function */
		private static var serviceCallFaultHandler : Function;
		
		/** strict flag to enable further runtime validation */
		private static var mediateBubbledEvents : Boolean = false;
		
		/** strict flag to enable further runtime validation */
		private static var injectionEvent : String;
		
		/** verbose flag to enable/disable logging */
		private static var verbose : Boolean = true;
		
		/** log level */
		private static var logEventLevel : int = LogEventLevel.WARN;
		
		/** Static getInstance method */
		public static function getInstance() : Swiz {
			if ( _applicationFactory == null ) {
				lock = true;
				_applicationFactory = new Swiz();
				lock = false;
			}
			return _applicationFactory;
		}
		
		/** Static loadBeans method. */
		public static function loadBeans( beanLoaders : Array ) : Swiz {
			return getInstance().loadBeans( beanLoaders );
		}
		
		/** Static addBean method. */
		public static function addBean( beanId : String, bean : Object ) : void {
			getInstance().addBean( beanId, bean );
		}
		
		/** Static getBean method. */
		public static function getBean( beanId : String ) : Object {
			return getInstance().getBean( beanId );
		}
		
		/** Static containsBean method. */
		public static function containsBean( beanId : String ) : Object {
			return getInstance().containsBean( beanId );
		}
		
		/** Static autowire method. */
		public static function autowire( obj : Object ) : void {
			getInstance().autowire( obj );
		}
		
		/** Static setStrict method. */
		public static function setStrict( strict : Boolean, eventPackage : String = null ) : Swiz {
			return getInstance().setStrict( strict, eventPackage );
		}
		
		/** Static isStrict method */
		public static function isStrict() : Boolean {
			return strict;
		}
		
		/** Static setStrict method. */
		public static function setMediateBubbledEvents( mediate : Boolean ) : Swiz {
			return getInstance().setMediateBubbledEvents( mediate );
		}
		
		/** Static bubbledEventsMediated method */
		public static function bubbledEventsMediated() : Boolean {
			return mediateBubbledEvents;
		}
		
		/** Static setVerbose method. */
		public static function setVerbose( verbose : Boolean ) : Swiz {
			Swiz.verbose = verbose;
			return getInstance();
		}
		
		/** Static isVerbose method */
		public static function isVerbose() : Boolean {
			return verbose;
		}
		
		/** Static setVerbose method. */
		public static function setLogLevel( logEventLevel : int ) : Swiz {
			return getInstance().setLogLevel( logEventLevel );
		}
		
		/** Static registerWindow method. */
		public static function registerWindow( window : IEventDispatcher ) : void {
			return getInstance().registerWindow( window );
		}
		
		/** Static getLogLevel method */
		public static function hasLogLevel( logEventLevel : int ) : Boolean {
			return verbose && Swiz.logEventLevel <= logEventLevel;
		}
		
		/** Static addEventListener method delegates to ApplicationController. This is for convenience */
		public static function addEventListener( type : String, listener : Function, useCapture : Boolean = false, 
													priority : int = 0, useWeakReference : Boolean = false ) : void {
			CentralDispatcher.getInstance().addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		/** Static addEventListener method delegates to ApplicationController. This is for convenience */
		public static function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void {
			CentralDispatcher.getInstance().removeEventListener( type, listener, useCapture );
		}
		
		/** Static method to dispatch events by name. Delegates to ApplicationController */
		public static function dispatch( type : String ) : Boolean {
			return CentralDispatcher.getInstance().dispatch( type );
		}
		
		/** Static method to dispatch events by name. Delegates to ApplicationController */
		public static function dispatchEvent( event : Event ) : Boolean {
			return CentralDispatcher.getInstance().dispatchEvent( event );
		}
		
		/** Static method to execute Async calls with dynamic responders */
		public static function executeServiceCall( call : AsyncToken, resultHandler : Function, faultHandler : Function = null,
													eventArgs : Array = null ) : void {
			if ( faultHandler == null && serviceCallFaultHandler != null )
				faultHandler = serviceCallFaultHandler;
			
			call.addResponder( new DynamicResponder( resultHandler, faultHandler, eventArgs ) );
		}
		
		/** Static method to execute URLLoader calls */
		public static function executeURLRequest( request : URLRequest, resultHandler : Function, faultHandler : Function = null, progressHandler : Function = null, httpStatusHandler : Function = null,
												  eventArgs : Array = null ) : void {
			if ( faultHandler == null && serviceCallFaultHandler != null )
				faultHandler = serviceCallFaultHandler;
			
			var dynamicURLRequest:DynamicURLRequest = new DynamicURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, eventArgs );
		}
		
		/** Static method to create dynamic controllers */
		public static function createCommand( delayedCall : Function, args : Array, resultHandler : Function, faultHandler : Function = null, eventArgs : Array = null ) : DynamicCommand {
			return new DynamicCommand( delayedCall, args, resultHandler, faultHandler, eventArgs );
		}
		
		public function Swiz() {
			if ( !lock )
				throw new Error( "ApplicationFactory can only be defined once, if you are defining it in mxml." );
			
			_beanFactory = new BeanFactory();
			_centralDispatcher = CentralDispatcher.getInstance();
			// set default injection point
			setInjectionEvent( "preinitialize" );
			
			// new, attach an autowire event handler to Application.application
			if ( hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "Attaching application event listeners..." );
			
			Swiz.systemManager.addEventListener( Event.REMOVED_FROM_STAGE, handleRemoveEvent, true );
		}
		
		/** non-static setStrict to support method chaining */
		public function setStrict( strict : Boolean, eventPackage : String = null ) : Swiz {
			Swiz.strict = strict;
			if ( eventPackage != null ) {
				addEventPackage( eventPackage );
			}
			return getInstance();
		}
		
		public function setServiceCallFaultHandler( f : Function ) : Swiz {
			Swiz.serviceCallFaultHandler = f;
			return getInstance();
		}
		
		public function setMediateBubbledEvents( mediate : Boolean ) : Swiz {
			Swiz.mediateBubbledEvents = mediate;
			
			return getInstance();
		}
		
		public function setInjectionEvent( event : String ) : Swiz {
			if ( Swiz.injectionEvent != null && Swiz.injectionEvent != event && Swiz.application.hasEventListener( Swiz.injectionEvent ) ) {
				Swiz.application.removeEventListener( Swiz.injectionEvent, handleAutowireEvent, true );
				Swiz.systemManager.removeEventListener( Swiz.injectionEvent, sysMgrInjectionProxy, true );
			}
			
			if( Swiz.injectionEvent == event )
				return this;
			
			Swiz.injectionEvent = event;
			
			// priority of 50 means injection listeners will fire after bindings but before regular listeners
			Swiz.application.addEventListener( Swiz.injectionEvent, handleAutowireEvent, true, 50 );
			Swiz.systemManager.addEventListener( Swiz.injectionEvent, sysMgrInjectionProxy, true, 50 );
			
			return this;
		}
		
		/**
		 * Proxy method called by systemManager listener so we can make sure the target is a popup
		 * before acting on the event.
		 * 
		 * @param event The event that triggers injection.
		 */
		protected function sysMgrInjectionProxy( event : Event ) : void {
			if ( !Sprite( Swiz.application ).contains( event.target as DisplayObject ) ) {
				handleAutowireEvent( event );
			}
		}
		
		/**
		 *
		 * @param eventPackage e.g. com.domain.project.event
		 * @return the Swiz instance for method chaining
		 *
		 */
		public function addEventPackage( eventPackage : String ) : Swiz {
			eventPackages.push( eventPackage );
			return getInstance();
		}
		
		/**
		 *
		 * @param viewPackage e.g. com.domain.project.view
		 * @return the Swiz instance for method chaining
		 *
		 */
		public function addViewPackage( viewPackage : String ) : Swiz {
			viewPackages.push( viewPackage );
			return getInstance();
		}
		
		/**
		 * convenience method to reset viewPackages
		 * primary used for unit testing
		 */
		public function resetViewPackages() : void {
			viewPackages = [];
		}
		
		/**
		 *
		 * @return Array of event packages
		 *
		 */
		public function getEventPackages() : Array {
			return getInstance().eventPackages;
		}
		
		/**
		 *
		 * @return Array of view packages
		 *
		 */
		public function getViewPackages() : Array {
			return getInstance().viewPackages;
		}
		
		/** non-static setStrict to support method chaining */
		public function setVerbose( verbose : Boolean ) : Swiz {
			Swiz.verbose = verbose;
			return getInstance();
		}
		
		/** non-static setLogLevel to support method chaining */
		public function setLogLevel( logEventLevel : int ) : Swiz {
			Swiz.logEventLevel = logEventLevel;
			return getInstance();
		}
		
		public function loadBeans( beanLoaders : Array ) : Swiz {
			
			// pass the bean loaders to the factory to load
			_beanFactory.loadBeans( beanLoaders );
			
			// dispatch an init complete event
			_centralDispatcher.dispatch( INIT_COMPLETE );
			
			// for advanced configuration, I will return swiz
			return this;
		}
		
		/** Calls addBean on the bean factory */
		public function addBean( beanId : String, bean : Object ) : void {
			_beanFactory.addBean( beanId, bean );
		}
		
		/** Calls getBean on the bean factory */
		public function getBean( beanId : String ) : Object {
			return _beanFactory.getBean( beanId );
		}
		
		/** Calls getBeanByType on the bean factory */
		public function getBeanByType( type : String ) : Array {
			return _beanFactory.getBeanByType( type );
		}
		
		/** Calls containsBean on the bean factory */
		public function containsBean( beanId : String ) : Boolean {
			return _beanFactory.containsBean( beanId );
		}
		
		/** Calls autowire on the bean factory */
		public function autowire( obj : Object ) : void {
			_beanFactory.autowire( obj );
		}
		
		private function isPotentialAutowireTarget( className : String ) : Boolean {
			
			// when viewPackages are defined only take views into consideration which are from the defined package(s)
			if ( viewPackages.length ) {
				// check if the class is in a viewPackage
				for each( var viewPackage:String in viewPackages ) {
					if ( className.indexOf(viewPackage) != -1 ) {
						return true;
					}
				}
				return false;
				
			// when no viewPackages are defined ignore at least internal classes with underscore or from the flash.* or mx.* or for Flex 4 spark.* package
			} else if ( className.indexOf( "mx" ) == 0 || className.indexOf( "flash" ) == 0 || className.indexOf( "_" ) != -1 || className.indexOf( "spark" ) == 0 ) {
				if ( hasLogLevel( LogEventLevel.DEBUG ) ){
					logger.debug( "ignore view " + className );
				}
				return false;
			}
			
			return true;
		}
		
		private function handleAutowireEvent( e : Event ) : void {
			var className:String = getQualifiedClassName( e.target );

			var isMainApp:Boolean = false;
			
			if ( CONFIG::flex4 ) {
				if( className.indexOf( "WindowedApplicationSkin" ) != -1 ){
					isMainApp = true;
				}
			} else {
				_appClassName ||= getQualifiedClassName( Swiz.application );
				isMainApp = _appClassName == className;
			}
			
			
			if ( isPotentialAutowireTarget( className ) || isMainApp ) {
				if ( hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "autowire {0} for added to stage event.", className );
				
				// In Flex 4 only the application skin but not the class itself gets added to the display chain
				// so we explicitly have to autowire the hostComponent of the skin which is the actual application class instance
				if ( CONFIG::flex4 && isMainApp ) {
					autowire( e.target.hostComponent );
				} else {
					autowire( e.target );
				}
				
				// check if the view needs to be autowired to a bean via [Autowire( view="true" )]
				if ( autowiredViews != null && autowiredViews[ className ] != null ) {
					// width and height of a view are still 0 when not at creationComplete
					// if this is the case add event listener and wire together afterwards
					if ( e.target.width == 0 && e.target.height == 0 ) {
						e.target.addEventListener( FlexEvent.CREATION_COMPLETE, function( ccEvent : FlexEvent ) : void {
								autowireView( className, e.target );
							}, false, 0, false );
					} else {
						autowireView( className, e.target );
					}
				}
			}
		}
		
		protected function autowireView( className : String, view : Object ) : void {
			var a:Array = autowiredViews[className];
			for each ( var o : Object in a ) {
				if ( hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "autowireView {0} into bean {1}.{2}", className, o.target, o.property );
				o.target[o.property] = view;
			}
		}
		
		private function handleRemoveEvent( e : Event ) : void {
			var className:String = getQualifiedClassName( e.target );
			if ( isPotentialAutowireTarget( className ) ) {
				if ( hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "unwiring {0} for removed from stage event.", className );
				_beanFactory.unwire( e.target );
			}
		}
		
		/**
		 * If you are using AIR with native windows you have to explicitly
		 * register new windows so Swiz can listen for added/removed views
		 * to inject beans and create dynamic mediators.
		 *
		 * Be sure to registerWindow BEFORE you open it to have things autowired correctly
		 *
		 * @param window Window reference, the param should be typed mx.core.Window
		 * but to avoid an AIR dependency we simply type it IEventDispatcher because
		 * we are only interested in adding event listeners
		 *
		 */
		public function registerWindow( window : IEventDispatcher ) : void {
			if ( hasLogLevel( LogEventLevel.INFO ) ) {
				logger.info( "registerWindow {0}", window );
				
			}
			window.addEventListener( Event.ADDED_TO_STAGE, handleAutowireEvent, true );
			window.addEventListener( Event.REMOVED_FROM_STAGE, handleRemoveEvent, true );
			autowire( window );
		}
	
	
	}
}