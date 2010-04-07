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
		function get name():*;
		function set name( value:* ):void;
		
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
		
		/**
		 * Get metadata tag by name
		 */
		function getMetadataTagByName( name:String ):IMetadataTag;
		  
		/**
		 * Has metadata tag by name
		 */
		function hasMetadataTagByName( name:String ):Boolean;
	}
}