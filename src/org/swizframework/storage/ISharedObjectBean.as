package org.swizframework.storage {
	
	public interface ISharedObjectBean {
		/**
		 *
		 * @param path SharedObject localPath value. default is "/"
		 *
		 */
		function set localPath( path : String ) : void;
		
		/**
		 *
		 * @param name SharedObject name value.
		 *
		 */
		function set name( name : String ) : void;
		
		/**
		 *
		 * @return Size of the SharedObject
		 *
		 */
		function get size() : Number;
		
		/**
		 * clears the SharedObject data
		 */
		function clear() : void;
		
		/**
		 *
		 * @param name Name of the SharedObject data value
		 * @return Boolean if the value already exists
		 *
		 */
		function hasValue( name : String ) : Boolean;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional init value. Default is null.
		 * @return SharedObject value for the given name
		 *
		 */
		function getValue( name : String, initValue : * = null ) : *;
		
		/**
		 *
		 * @param name Value name
		 * @param value Value reference
		 *
		 */
		function setValue( name : String, value : * ) : void;
		
		function getString( name : String, initValue : String = null ) : String;
		function setString( name : String, value : String ) : void;
		
		function getBoolean( name : String, initValue : Boolean = undefined ) : Boolean;
		function setBoolean( name : String, value : Boolean ) : void;
		
		function getNumber( name : String, initValue : Number = NaN ) : Number;
		function setNumber( name : String, value : Number ) : void;
		
		function getInt( name : String, initValue : int = undefined ) : int;
		function setInt( name : String, value : int ) : void;
	}
}