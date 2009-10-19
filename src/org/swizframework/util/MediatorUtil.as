package org.swizframework.util {
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import org.swizframework.Swiz;
	
	public class MediatorUtil {
		
		private static const logger : ILogger = Log.getLogger( "org.swizframework.util.MediatorUtil" );
		
		public function MediatorUtil() {
		}
		
		/**
		 *
		 * @param eventName like com.domain.project.event.FooEvent.FOO
		 * @return eventConstant name like FOO or null if no constant is found
		 *
		 */
		protected static function getEventConstantName( eventName : String ) : String {
			// Check if event const is used which we expect to be UPPERCASE
			var eventTypeConstName:String = eventName.substring( eventName.lastIndexOf( "." ) + 1, eventName.length );
			var re:RegExp = new RegExp( "[A-Z0-9_]", "g" );
			var match:Array = eventTypeConstName.match( re );
			if ( eventTypeConstName.length == match.length ) {
				return eventTypeConstName;
			}
			return null;
		}
		
		/**
		 * Validate eventName with "." since we expect them to be full qualified classname like com.foo.FooEvent.BAR
		 * without a "." we consider it to be a message event dispatched like Swiz.dispatch("initApp")
		 *
		 * @param eventName
		 * @param eventProperties
		 * @return eventName
		 *
		 */
		public static function validateEvent( eventName : String, eventProperties : String ) : String {
			if ( eventName.indexOf( "." ) != -1 ) {
				var eventTypeConstName:String = getEventConstantName( eventName );
				if ( eventTypeConstName == null ) {
					throw new Error( "Event name does not contain constant with the event type value: " + eventName + "\nExpected syntax: com.foo.event.FooEvent.FOO" );
					return null;
				}
				
				
				// remove constant from event
				var className:String = eventName.substring( 0, eventName.lastIndexOf( "." ) );
				
				// variable for the class we try to evaluate
				var c:Class;
				
				var eventPackages:Array = Swiz.getInstance().getEventPackages();
				if ( eventPackages != null && eventPackages.length > 0 ) {
					var tempClassName:String;
					for each ( var eventPackage : String in eventPackages ) {
						tempClassName = eventPackage + "." + className;
						try {
							// if the tempClassName does not exist
							// we catch the error and go on in the loop
							// iterating over the eventPackages
							c = getDefinitionByName( tempClassName ) as Class;
							className = tempClassName;
							if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
								logger.info( "adding strictEventPackage " + eventPackage + " result in full qualified class name " + className );
							break;
						} catch ( e : ReferenceError ) {
						}
					}
				}
				
				// if no event packages are declared or the event name
				// does not match with defined event packages
				if ( c == null ) {
					try {
						c = getDefinitionByName( className ) as Class;
						if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
							logger.info( "found class", className );
					} catch ( e : ReferenceError ) {
						var props:Array = null;
						if ( eventProperties != null ) {
							props = eventProperties.split( "," );
						}
						
						var template:String = TemplateUtil.createEventTemplate( className, eventTypeConstName, props );
						if ( Swiz.hasLogLevel( LogEventLevel.ERROR ) )
							logger.error( className + " not found. Template:\n" + template );
						
						throw new Error( className + " not found to create dynamic mediator." );
						return null;
					}
				}
				
				var eventClassXML:XML = describeType( c );
				
				// check if class has constant eventTypeConstName 
				var node:XMLList = eventClassXML.constant.(@name == eventTypeConstName);
				if ( node.length() == 0 ) {
					throw new Error( "Class " + className + " has no const " + eventTypeConstName );
				}
				// check if constant is of type String
				var constType:String = node.@type;
				if ( constType != "String" ) {
					throw new Error( className + "." + eventTypeConstName + " is not typed String but " + constType );
				} else {
					// evaluate the final eventName
					eventName = c[eventTypeConstName];
				}
				
				// check if class has member variables
				if ( eventProperties != null ) {
					var properties:Array = eventProperties.split( "," );
					for each ( var variable : String in properties ) {
						var variableList:XMLList = eventClassXML.factory.variable.( @name == variable );
						var accessorList:XMLList = eventClassXML.factory.accessor.( @name == variable );
						if ( variableList.length() == 0 && accessorList.length() == 0 ) {
							throw new Error( "Unable to mediate event " + eventName + "! Member variable " + variable + " does not exists" );
						}
					}
				}
				
			}
			return eventName;
		}
	
	
	}
}