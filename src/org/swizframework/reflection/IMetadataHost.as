package org.swizframework.reflection
{
	/**
	 * IMetadataHost is a representation of a public property or method
	 * decorated with some kind of metadata so name collisions should be impossible.
	 */
	public interface IMetadataHost
	{
		// name of property/method/class
		function get name():String;
		function set name( value:String ):void;
		
		function get type():Class;
		function set type( value:Class ):void;
		
		[ArrayElementType( "org.swizframework.reflection.IMetadataTag" )]
		
		function get metadataTags():Array;
		function set metadataTags( value:Array ):void;
	}
}