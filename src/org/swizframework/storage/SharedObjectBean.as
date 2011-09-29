/*
 * Copyright 2010 Swiz Framework Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.storage
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import org.swizframework.utils.logging.SwizLogger;
	
	public class SharedObjectBean extends EventDispatcher implements ISharedObjectBean
	{
		protected var logger:SwizLogger = SwizLogger.getLogger( this );
		
		private var so:SharedObject;
		
		private var _path:String = "/";
		private var _name:String = "swizSharedObject";
		
		/**
		 * @inheritDoc
		 */
		public function set localPath( path:String ):void
		{
			_path = path;
			invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		public function set name( name:String ):void
		{
			_name = name;
			invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get size():Number
		{
			if( so != null )
			{
				return so.size
			}
			return NaN;
		}
		
		public function SharedObjectBean()
		{
			super();
			invalidate();
		}
		
		protected function invalidate():void
		{
			so = SharedObject.getLocal( _name, _path );
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear():void
		{
			so.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasValue( name:String ):Boolean
		{
			return so.data[name] != undefined;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getValue( name:String, initValue:* = null ):*
		{
			var o:Object = so.data;
			if( o[name] == null && initValue != null )
			{
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setValue( name:String, value:* ):void
		{
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getString( name:String, initValue:String = null ):String
		{
			var o:Object = so.data;
			if( o[name] == null && initValue != null )
			{
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setString( name:String, value:String ):void
		{
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getBoolean( name:String, initValue:Boolean = false ):Boolean
		{
			var o:Object = so.data;
			if( o[name] == null )
			{
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setBoolean( name:String, value:Boolean ):void
		{
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getNumber( name:String, initValue:Number = NaN ):Number
		{
			var o:Object = so.data;
			if( o[name] == null )
			{
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setNumber( name:String, value:Number ):void
		{
			var o:Object = so.data;
			o[name] = value;
			so.flush();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getInt( name:String, initValue:int = -1 ):int
		{
			var o:Object = so.data;
			if( o[name] == null )
			{
				o[name] = initValue;
				so.flush();
			}
			
			return o[name];
		}
		
		/**
		 * @inheritDoc
		 */
		public function setInt( name:String, value:int ):void
		{
			var o:Object = so.data;
			o[name] = value;
			so.flush();
			dispatchEvent( new Event( "intChange" ) );
		}
	}
}