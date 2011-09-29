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

package org.swizframework.core
{
	import org.swizframework.reflection.TypeDescriptor;
	
	[DefaultProperty( "source" )]
	
	public class Bean
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var _source:*;
		protected var _name:String;
		protected var _typeDescriptor:TypeDescriptor;
		protected var _beanFactory:IBeanFactory;
		protected var _initialized:Boolean;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Source
		 */
		public function get source():*
		{
			return _source;
		}
		
		public function set source( value:* ):void
		{
			_source = value;
		}
		
		/**
		 * Name
		 */
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		/**
		 * Type Descriptor
		 */
		public function get typeDescriptor():TypeDescriptor
		{
			return _typeDescriptor;
		}
		
		public function set typeDescriptor(value:TypeDescriptor):void
		{
			_typeDescriptor = value;
		}
		
		/**
		 * BeanFactory
		 */
		public function get beanFactory():IBeanFactory
		{
			return _beanFactory;
		}
		
		public function set beanFactory(value:IBeanFactory):void
		{
			_beanFactory = value;
		}
		
		/**
		 * Initialzed
		 */
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void
		{
			_initialized = value;
		}
		
		public function get type():*
		{
			return source;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean( source:* = null, name:String = null, typeDescriptor:TypeDescriptor = null )
		{
			this.source = source;
			this.name = name;
			this.typeDescriptor = typeDescriptor;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function toString():String
		{
			return "Bean{ source: " + source + ", name: " + name + " }";
		}
	}
}