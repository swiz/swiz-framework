package org.swizframework.reflect
{
	public interface IMetadataHost
	{
		function get name():String;
		function set name( value:String ):void;
		
		function get metadataTags():Array;
		function set metadataTags( value:Array ):void;
	}
}