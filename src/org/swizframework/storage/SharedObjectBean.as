package org.swizframework.storage {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class SharedObjectBean extends EventDispatcher implements ISharedObjectBean {
		private static const logger : ILogger = Log.getLogger( "org.swizframework.storage.SharedObjectBean" );
		
		private var so:SharedObject;
		
		private var _path:String = "/";
		private var _name:String;
		
		/**
		 *
		 * @param path SharedObject localPath value. default is "/"
		 *
		 */
		public function set localPath( path : String ) : void {
			_path = path;
			invalidate();
		}
		
		/**
		 *
		 * @param name SharedObject name value.
		 *
		 */
		public function set name( name : String ) : void {
			_name = name;
			invalidate();
		}
		
		/**
		 *
		 * @return size of the SharedObject
		 *
		 */
		public function get size() : Number {
			if ( so != null ) {
				return so.size
			}
			return NaN;
		}
		
		public function SharedObjectBean() {
		}
		
		protected function invalidate() : void {
			so = SharedObject.getLocal( _name, _path );
		}
		
		/**
		 * clears the allocated SharedObject
		 *
		 */
		public function clear() : void {
			so.clear();
		}
		
		/**
		 *
		 * @param name of the stored value
		 * @return if the value has been set.
		 *
		 */
		public function hasValue( name : String ) : Boolean {
			return so.data[name] != undefined;
		}
		
		public function getValue( name : String, initValue : * = null ) : * {
			var o:Object = so.data;
			if ( o[name] == null && initValue != null ) {
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		public function setValue( name : String, value : * ) : void {
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		public function getString( name : String, initValue : String = null ) : String {
			var o:Object = so.data;
			if ( o[name] == null && initValue != null ) {
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		public function setString( name : String, value : String ) : void {
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		public function getBoolean( name : String, initValue : Boolean = undefined ) : Boolean {
			var o:Object = so.data;
			if ( o[name] == null ) {
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		public function setBoolean( name : String, value : Boolean ) : void {
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		public function getNumber( name : String, initValue : Number = NaN ) : Number {
			var o:Object = so.data;
			if ( o[name] == null ) {
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		public function setNumber( name : String, value : Number ) : void {
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		public function getInt( name : String, initValue : int = undefined ) : int {
			var o:Object = so.data;
			if ( o[name] == null ) {
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		public function setInt( name : String, value : int ) : void {
			var o:Object = so.data;
			o[name] = value;
			so.flush();
			dispatchEvent( new Event( "intChange" ) );
		}
	}
}