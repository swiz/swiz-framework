package org.swizframework.reflection
{
	/**
	 * IMetadataHost is a representation of a public property or method
	 * decorated with some kind of metadata so name collisions should be impossible.
	 */
	public interface IMetadataTag
	{
		function get name():String;
		function set name( value:String ):void;
		
		[ArrayElementType( "org.swizframework.reflection.MetadataArg" )]
		
		function get args():Array;
		function set args( value:Array ):void;
		
		function get host():IMetadataHost;
		function set host( value:IMetadataHost ):void;
		
		function hasArg( argName:String ):Boolean;
		function getArg( argName:String ):MetadataArg;
	}
}