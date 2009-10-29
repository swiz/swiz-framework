package org.swizframework.reflection
{
	/**
	 * IMetadataHost is a representation of a public property or method
	 * decorated with some kind of metadata so name collisions should be impossible.
	 */
	public interface IMetadataHost
	{
		function get hostType():String;
		function set hostType( value:String ):void;
		
		function get name():String;
		function set name( value:String ):void;
		
		function get metadataTags():Array;
		function set metadataTags( value:Array ):void;
		
		function get isBindable():Boolean;
	}
}