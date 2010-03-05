package org.swizframework.core
{
	public interface ISwizConfig
	{
		// ========================================
		// properties
		// ========================================
		
		/**
		 * Flag to enable runtime validation of mediated events.
		 * If set to true, <code>[Mediate( event="FooEvent.FOO", properties="username, password" )]</code>
		 * will cause Swiz to validate that <code>FooEvent</code> exists, has a constant named <code>FOO</code>
		 * and has member variables named <code>username</code> and <code>password</code>.
		 *
		 * @param strict True or false flag
		 * @default false
		 */
		function get strict():Boolean;
		function set strict( value:Boolean ):void;
		
		/**
		 * Swiz will listen for this event and perform injections in response.
		 * Default value is <code>addedToStage</code>. Potential alternatives are <code>preinitialize</code>,
		 * <code>initialize</code>, <code>creationComplete</code> and <code>addedToStage</code>.
		 * Any event can be used, but you should obviously favor events that happen once per component.
		 *
		 * @param injectionEvent Event type that will trigger injections.
		 * @default flash.events.Event.ADDED_TO_STAGE
		 */
		function get injectionEvent():String;
		function set injectionEvent( value:String ):void;
		
		/**
		 * Swiz will listen for the injection event at the specified priority.
		 * Default value is 50.
		 * The priority level of the event listener. The priority is designated by a signed 32-bit integer.
		 * The higher the number, the higher the priority.
		 *
		 * @param injectionEventPriority The injection event priority.
		 * @default 50
		 */
		function get injectionEventPriority():int;
		function set injectionEventPriority( value:int ):void;
		
		/**
		 * Swiz will listen for the injection event at this specified injection event phase and perform injections in
		 * response. Default value is <code>flash.events.EventPhase.CAPTURING_PHASE</code>. Valid options are
		 * <code>flash.events.EventPhase.BUBBLING_PHASE</code> and <code>flash.events.EventPhase.CAPTURE_PHASE</code>.
		 *
		 * @param injectionEventPhase The flash.events.EventPhase constant associated with the desired event phase.
		 * @default flash.events.EventPhase.CAPTURING_PHASE
		 */
		function get injectionEventPhase():uint;
		function set injectionEventPhase( value:uint ):void;
		
		/**
		 * The optional <code>injectionMarkerFunction</code> property specifies a function that Swiz will call when
		 * handling an injection event to evaluate whether to process metadata on the associated object instance.
		 * Advanced developers can use this property to specify a function to detect 'marker' properties or interfaces.
		 *
		 * This function should conform to the following signature:
		 * <code>f( instance:Object ):Boolean</code>
		 * where the return value is true if the specified instance should be processed for metadata.
		 *
		 * @param injectionMarkerFunction The injection marker function.
		 * @default null
		 */
		function get injectionMarkerFunction():Function;
		function set injectionMarkerFunction( value:Function ):void;
		
		/**
		 * When using <code>strict</code> mode, <code>eventPackages</code> allows you to use
		 * unqualified class/event names in your <code>[Mediate]</code> metadata. For example,
		 * <code>[Mediate( event="com.foo.events.MyEvent.FOO" )]</code> can be shortened to
		 * <code>[Mediate( event="MyEvent.FOO" )]</code> if <code>com.foo.events</code> is
		 * provided as an eventPackage.
		 *
		 * @param eventPackages An Array of Strings or a single String that will be split on ","
		 * @default []
		 */
		function get eventPackages():Array;
		function set eventPackages( value:* ):void;
		
		/**
		 * If this property is set, Swiz will only introspect and potentially inject into components
		 * added to the display list that match a provided package. It is primarily for performance
		 * purposes and its use is strongly recommended. Beans declared in an <code>IBeanProvider</code>
		 * are always eligible for injection.
		 *
		 * @param viewPackages An array of Strings or a single String that will be split on ","
		 * @default []
		 */
		function get viewPackages():Array;
		function set viewPackages( value:* ):void;
		
		/**
		 * Default Fault Handler
		 *
		 * @param faultHandler A fault handling Function.
		 * @default null
		 */
		function get defaultFaultHandler():Function;
		function set defaultFaultHandler( faultHandler:Function ):void;
	}
}