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
		 * Setting to true will cause Swiz to listen for mediated events at the application root.
		 * This allows you to mediate any event that bubbles (don't forget to override <code>clone()</code>)
		 * rather than having to use Swiz's central dispatcher. If set to false, Swiz can only mediate events
		 * dispatched via <code>Swiz.dispatch( "myEventType" )</code> and
		 * <code>Swiz.dispatchEvent( new FooEvent( FooEvent.FOO ) )</code>.
		 *
		 * @param mediate True or false flag
		 * @default true
		 */
		function get mediateBubbledEvents():Boolean;
		function set mediateBubbledEvents( value:Boolean ):void;
		
		/**
		 * Swiz will listen for this event in the capture phase and perform injections in
		 * response. Default value is <code>preinitialize</code>. Potential alternatives are
		 * <code>initialize</code>, <code>creationComplete</code> and <code>addedToStage</code>.
		 * Any event can be used, but you should obviously favor events that happen once per component.
		 *
		 * @param Event type that will trigger injections.
		 * @default flash.events.Event.ADDED_TO_STAGE
		 */
		function get injectionEvent():String;
		function set injectionEvent( value:String ):void;
		
		/**
		 * Swiz uses the internal Flex logging API and you can define a specific logEventLevel to
		 * instruct Swiz about what kind of events you wish to capture in your logger.
		 * 
		 * @param logEventLevel is the desired log event level.
		 * @default LogEventLevel.WARN
		 * @see mx.logging.LogEventLevel
		 *
		 */		
		function get logEventLevel():int;
		function set logEventLevel( value:int ):void;
		
		/**
		 * When using <code>strict</code> mode, <code>eventPackages</code> allows you to use
		 * unqualified class/event names in your <code>[Mediate]</code> metadata. For example,
		 * <code>[Mediate( event="com.foo.events.MyEvent.FOO" )]</code> can be shortened to
		 * <code>[Mediate( event="MyEvent.FOO" )]</code> if <code>com.foo.events</code> is
		 * provided as an eventPackage.
		 *
		 * @param eventPackages can be a real array of Strings or a single String that will be split on ","
		 * @default []
		 */
		function get eventPackages():Array;
		function set eventPackages( value:* ):void;
		
		/**
		 * If this property is set, Swiz will only introspect and potentially autowire components
		 * added to the display list that match a provided package. It is primarily for performance
		 * purposes and its use is strongly recommended. Beans declared in a <code>BeanProvider</code>
		 * are always eligible for autowiring.
		 *
		 * @param viewPackages can be a real array of Strings or a single String that will be split on ","
		 * @default []
		 */
		function get viewPackages():Array;
		function set viewPackages( value:* ):void;
	}
}