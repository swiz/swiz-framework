package org.swizframework.reflection
{
	/**
	 * The IMetadataTag interface is a representation of a metadata tag
	 * that has been defined in source code.
	 */
	public interface IMetadataTag
	{
		/**
		 * Name of the tag, e.g. "Bindable" from [Bindable].
		 */
		function get name():String;
		function set name( value:String ):void;

		[ArrayElementType( "org.swizframework.reflection.MetadataArg" )]
		/**
		 * Array of arguments defined in the tag.
		 *
		 * @see org.swizframework.reflection.MetadataArg
		 */
		function get args():Array;
		function set args( value:Array ):void;

		/**
		 * Element (class, method or property) on which the metadata tag is defined.
		 */
		function get host():IMetadataHost;
		function set host( value:IMetadataHost ):void;

		/**
		 * @param argName Name of argument whose existence on this tag will be checked.
		 * @return Flag indicating whether or not this tag contains an argument for the given name.
		 */
		function hasArg( argName:String ):Boolean;

		/**
		 * @param argName Name of argument to retrieve.
		 * @return Argument for the given name.
		 */
		function getArg( argName:String ):MetadataArg;
		
		function copyFrom( metadataTag:IMetadataTag ):void;
	}
}