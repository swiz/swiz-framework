package org.swizframework.reflect
{
	public interface IMetadataHost
	{
		function get type():String;
		function set type( value:String ):void;
		
		function get name():String;
		function set name( value:String ):void;
		
		function get metadataTags():Array;
		function set metadataTags( value:Array ):void;
		
		function get isBindable():Boolean;
	}
}