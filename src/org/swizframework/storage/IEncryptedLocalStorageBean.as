package org.swizframework.storage {
	
	/**
	 * The IEncryptedLocalStorageBean should be used as the type of the autowired variable.
	 * Define the implementation <code>EncryptedLocalStorageBean</code> in a <code>BeanLoader</code>
	 *
	 * The IEncryptedLocalStorageBean wrappes the functionality of the EncryptedLocalStorageBean
	 * to supply easier access and to avoid repetitive code.
	 */
	public interface IEncryptedLocalStorageBean {
		
		/**
		 * Resets the ELS and removes all values.
		 *
		 */
		function reset() : void;
		
		
		/**
		 * Removes an item out of the EncryptedLocalStorage pass the item name.
		 *
		 * @param name Name of the item to be removed
		 *
		 */
		function removeItem( name : String ) : void;
		
		/**
		 * Returns an item expected to contain a String value of the ELS.
		 * If the item is not defined yet null is returned.
		 *
		 * @param name Name of the item containing a String.
		 * @return Item values as String.
		 *
		 */
		function getString( name : String ) : String;
		
		/**
		 * Set an ELS item with a String value.
		 *
		 * @param name Name if the item to be set.
		 * @param s Value of the item.
		 * @param stronglyBound
		 *
		 */
		function setString( name : String, s : String, stronglyBound : Boolean = false ) : void;
		
		/**
		 * Returns an item expected to contain a Boolean value of the ELS.
		 * If the item is not defined yet undefined is returned.
		 *
		 * @param name Name of the item.
		 * @return Item value as Boolean.
		 *
		 */
		function getBoolean( name : String ) : Boolean;
		
		/**
		 * Set an ELS item with a boolean value.
		 *
		 * @param name Name if the item to be set.
		 * @param b Value of the item
		 * @param stronglyBound
		 *
		 */
		function setBoolean( name : String, b : Boolean, stronglyBound : Boolean = false ) : void;
		
		/**
		 * Returns an item as Object of the ELS.
		 * If the item is not defined yet null is returned.
		 *
		 * @param name Name if the item containing an Object.
		 * @return Item as Object.
		 *
		 */
		function getObject( name : String ) : Object;
		
		/**
		 * Set an ELS item with an Object.
		 *
		 * @param name Name if the item to be set.
		 * @param o Object reference of the item to be set.
		 * @param stronglyBound
		 *
		 */
		function setObject( name : String, o : Object, stronglyBound : Boolean = false ) : void;
	}
}