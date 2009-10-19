package org.swizframework.util {
	import mx.utils.StringUtil;
	
	public class TemplateUtil {
		
		/**
		 * 0 is placeholder for package
		 * 1 is placeholder for classname
		 * 2 is placeholder for type
		 * 3 is placeholder for member variables
		 * 4 is placeholder for constructor params
		 * 5 is placeholder for params assignments
		 */
		private static const eventTemplate : XML = <root>
				<template><![CDATA[package {0}
{
	import flash.events.Event;
	
	public class {1} extends Event
	{
		public static const {2}:String = "{0}.{1}.{2}";
		
{3}
		
		public function {1}(type:String{4})
		{
			super(type);
{5}
		}
	}
}]]></template></root>;
	
		/**
		 *
		 * @param eventName e.g. com.foo.MyEvent
		 * @param properties e.g. username,password
		 * @return Event as template String
		 *
		 */
		public static function createEventTemplate( eventName : String, typeConstName : String, properties : Array ) : String {
			// grab the package name out ot the full qualified classname
			var packageName:String = eventName.substring( 0, eventName.lastIndexOf( "." ) );
			// grab the class name out of the full qualified classname
			var className:String = eventName.substring( eventName.lastIndexOf( "." ) + 1, eventName.length );
			
			var members:String = "";
			var params:String = "";
			var assignments:String = "";
			if ( properties != null ) {
				params = ", ";
				for ( var i : uint = 0; i < properties.length; i++ ) {
					var property:String = properties[i] as String;
					
					members += "\t\tpublic var " + property + ":Object;";
					params += properties[i]  +":Object";
					assignments += "\t\t\tthis." + property + " = " + property + ";";
					
					if ( i < properties.length - 1 ) {
						params += ", ";
						members += "\n";
						assignments += "\n";
					}
				}
			}
			
			var s:String = eventTemplate.template;
			s = StringUtil.substitute( s, packageName, className, typeConstName, members, params, assignments );
			return s;
		}
	
	}
}