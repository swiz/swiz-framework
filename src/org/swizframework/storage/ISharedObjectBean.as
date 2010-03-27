package org.swizframework.storage
{
	public interface ISharedObjectBean
	{
		/**
		 *
		 * @param path SharedObject localPath value. default is "/"
		 *
		 */
		function set localPath( path : String ):void;
		
		/**
		 *
		 * @param name SharedObject name value.
		 *
		 */
		function set name( name : String ):void;
		
		/**
		 *
		 * @return Size of the SharedObject
		 *
		 */
		function get size():Number;
		
		/**
		 * clears the SharedObject data
		 */
		function clear():void;
		
		/**
		 *
		 * @param name Name of the value
		 * @return True if the value already exists. False if the value does not exist.
		 *
		 */
		function hasValue( name : String ):Boolean;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional initial value. Default is null.
		 * @return Untyped value
		 *
		 */
		function getValue( name : String, initValue : * = null ):*;
		
		/**
		 *
		 * @param name Value name
		 * @param value String value
		 *
		 */
		function setValue( name : String, value : * ):void;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional initial value. Default is null.
		 * @return String value
		 *
		 */
		function getString( name : String, initValue : String = null ):String;
		
		/**
		 *
		 * @param name Value name
		 * @param value String value
		 *
		 */
		function setString( name : String, value : String ):void;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional initial value. Default is false.
		 * @return Boolean value
		 *
		 */
		function getBoolean( name : String, initValue : Boolean = false ):Boolean;
		
		/**
		 *
		 * @param name Value name
		 * @param value Boolean value
		 *
		 */
		function setBoolean( name : String, value : Boolean ):void;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional initial value. Default is NaN.
		 * @return Number value
		 *
		 */
		function getNumber( name : String, initValue : Number = NaN ):Number;
		
		/**
		 *
		 * @param name Value name
		 * @param value Number value
		 *
		 */
		function setNumber( name : String, value : Number ):void;
		
		/**
		 *
		 * @param name Value name
		 * @param initValue Optional initial value. Default is -1.
		 * @return Integer value
		 *
		 */
		function getInt( name : String, initValue : int = -1 ):int;
		
		/**
		 *
		 * @param name Value name
		 * @param value Integer value
		 *
		 */
		function setInt( name : String, value : int ):void;
	}
}