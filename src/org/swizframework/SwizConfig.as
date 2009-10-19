package org.swizframework {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	public class SwizConfig extends EventDispatcher {
		
		protected static const logger : ILogger = Log.getLogger( "org.swizframework.SwizConfig" );
		
		// ========================================
		// strict
		// ========================================
		
		/**
		 * Backing variable for public <code>strict</code> setter.
		 */
		protected var _strict : Boolean = false;
		
		/**
		 * Flag to enable runtime validation of mediated events.
		 * If set to true, <code>[Mediate( event="FooEvent.FOO", properties="username, password" )]</code>
		 * will cause Swiz to validate that <code>FooEvent</code> exists, has a constant named <code>FOO</code>
		 * and has member variables named <code>username</code> and <code>password</code>.
		 *
		 * @param strict True or false flag
		 */
		public function set strict( strict : Boolean ) : void {
			_strict = strict;
		}
		
		// ========================================
		// mediateBubbledEvents
		// ========================================
		
		/**
		 * Backing variable for public <code>mediateBubbledEvents</code> setter.
		 */
		protected var _mediateBubbledEvents : Boolean = false;
		
		/**
		 * Setting to true will cause Swiz to listen for mediated events at the application root.
		 * This allows you to mediate any event that bubbles (don't forget to override <code>clone()</code>)
		 * rather than having to use Swiz's central dispatcher. If set to false, Swiz can only mediate events
		 * dispatched via <code>Swiz.dispatch( "myEventType" )</code> and
		 * <code>Swiz.dispatchEvent( new FooEvent( FooEvent.FOO ) )</code>.
		 *
		 * @param mediate True or false flag
		 */
		public function set mediateBubbledEvents( mediate : Boolean ) : void {
			_mediateBubbledEvents = mediate;
		}
		
		// ========================================
		// injectionEvent
		// ========================================
		
		/**
		 * Backing variable for public <code>injectionEvent</code> setter.
		 */
		protected var _injectionEvent : String = "preinitialize";
		
		/**
		 * Swiz will listen for this event in the capture phase and perform injections in
		 * response. Default value is <code>preinitialize</code>. Potential alternatives are
		 * <code>initialize</code>, <code>creationComplete</code> and <code>addedToStage</code>.
		 * Any event can be used, but you should obviously favor events that happen once per component.
		 *
		 * @param Event type that will trigger injections.
		 */
		public function set injectionEvent( event : String ) : void {
			_injectionEvent = event;
		}
		
		// ========================================
		// serviceCallFaultHandler
		// ========================================
		
		/**
		 * Backing variable for public <code>serviceCallFaultHandler</code> setter.
		 */
		protected var _serviceCallFaultHandler : Function;
		
		/**
		 * Global fault handler for service calls that do not have a specific fault handler assigned.
		 *
		 * @param Handler function
		 */
		public function set serviceCallFaultHandler( handler : Function ) : void {
			_serviceCallFaultHandler = handler;
		}
		
		// ========================================
		// logEventLevel
		// ========================================
		
		/**
		 * Backing variable for public <code>logEventLevel</code> setter.
		 */
		protected var _logEventLevel:int = LogEventLevel.WARN;
		
		/**
		 *
		 * @param logEventLevel for the swizframework internal logs (default is WARN)
		 * @see mx.logging.LogEventLevel
		 *
		 */
		public function set logEventLevel( logEventLevel : int ) : void {
			_logEventLevel = logEventLevel;
		}
		
		// ========================================
		// eventPackages
		// ========================================
		
		/**
		 * Backing variable for public <code>eventPackages</code> setter.
		 */
		protected var _eventPackages:Array;
		
		/**
		 * When using <code>strict</code> mode, <code>eventPackages</code> allows you to use
		 * unqualified class/event names in your <code>[Mediate]</code> metadata. For example,
		 * <code>[Mediate( event="com.foo.events.MyEvent.FOO" )]</code> can be shortened to
		 * <code>[Mediate( event="MyEvent.FOO" )]</code> if <code>com.foo.events</code> is
		 * provided as an eventPackage.
		 *
		 * @param eventPackages can be a real array of Strings or a single String that will be split on ","
		 */
		public function set eventPackages( eventPackages : * ) : void {
			if ( eventPackages is Array ) {
				_eventPackages = eventPackages as Array;
			} else if ( eventPackages is String ) {
				var s:String = eventPackages as String;
				s = s.replace( " ", "" );
				_eventPackages = s.split( "," );
			} else {
				throw new Error( "eventPackages set with unknown type. Supported types are Array or String." );
			}
		}
		
		// ========================================
		// viewPackages
		// ========================================
		
		/**
		 * Backing variable for public <code>viewPackages</code> setter.
		 */
		protected var _viewPackages:Array;
		
		/**
		 * If this property is set, Swiz will only introspect and potentially autowire components
		 * added to the display list that match a provided package. It is primarily for performance
		 * purposes and its use is strongly recommended. Beans declared in a <code>BeanLoader</code>
		 * are always eligible for autowiring.
		 *
		 * @param viewPackages can be a real array of Strings or a single String that will be split on ","
		 */
		public function set viewPackages( viewPackages : * ) : void {
			if ( viewPackages is Array ) {
				_viewPackages = viewPackages as Array;
			} else if ( viewPackages is String ) {
				var s:String = viewPackages as String;
				s = s.replace( " ", "" );
				_viewPackages = s.split( "," );
			} else {
				throw new Error( "viewPackages set with unknown type. Supported types are Array or String." );
			}
		}
		
		// ========================================
		// beanLoaders
		// ========================================
		
		protected var _beanLoaders:Array;
		
		/**
		 * Classes which Swiz will instantiate to create bean instances and perform autowiring.
		 *
		 * @param Array of BeanLoader class references
		 * @see org.swizframework.util.BeanLoader
		 */
		public function set beanLoaders( a : Array ) : void {
			_beanLoaders = a;
		}
		
		/**
		 * Constructor
		 */
		public function SwizConfig() {
			// wait for preinitialize to init Swiz
			// before that systemManager is not available yet
			Swiz.application.addEventListener( FlexEvent.PREINITIALIZE, preInitHandler, false, 50, true );
		}
		
		protected function preInitHandler( e : Event ) : void {
			Swiz.application.removeEventListener( FlexEvent.PREINITIALIZE, preInitHandler );
			
			var swizInstance:Swiz = Swiz.getInstance();
			
			swizInstance.setLogLevel( _logEventLevel );
			
			if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "Init Swiz" );
			
			swizInstance.setStrict( _strict );
			swizInstance.setMediateBubbledEvents( _mediateBubbledEvents );
			swizInstance.setInjectionEvent( _injectionEvent );
			
			if ( _serviceCallFaultHandler != null )
				swizInstance.setServiceCallFaultHandler( _serviceCallFaultHandler );
			
			if ( _eventPackages != null ) {
				for each ( var eventPackage : String in _eventPackages ) {
					swizInstance.addEventPackage( eventPackage );
				}
			}
			
			if ( _viewPackages != null ) {
				for each ( var viewPackage : String in _viewPackages ) {
					swizInstance.addViewPackage( viewPackage );
				}
			}
			
			if ( _beanLoaders != null )
				swizInstance.loadBeans( _beanLoaders );
		}
	}
}