package org.swizframework.reflection
{
	/**
	 * The IMetadataHost interface is a representation of a public property, method
	 * or class that is decorated with metadata.
	 */
	public interface IMetadataHost
	{
		/**
		 * Name of the property/method/class.
		 */
		function get name():String;
		function set name( value:String ):void;
		
		/**
		 * Type of the property/method/class.
		 */
		function get type():Class;
		function set type( value:Class ):void;
		
		[ArrayElementType( "org.swizframework.reflection.IMetadataTag" )]
		/**
		 * Array of metadata tags that decorate the property/method/class.
		 */
		function get metadataTags():Array;
		function set metadataTags( value:Array ):void;
	}
}