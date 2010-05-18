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

package org.swizframework.utils.test
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.Swiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.reflection.TypeCache;
	
	/**
	 * AutowiredTestCase provides a base class for unit testing that provides autowiring.
	 * A child test case should set the beanProvider and swizConfig properties in it's constructor. A new 
	 * Swiz Context will be created in the test's [Before] method.
	 */
	public class AutowiredTestCase extends EventDispatcher
	{
		/**
		 * Backing variable for <code>beanProvider</code> getter/setter.
		 */
		private var _beanProviders:Array;
		
		/**
		 * Backing variable for <code>swizConfig</code> getter/setter.
		 */
		private var _swizConfig:SwizConfig;
		
		/**
		 * Backing variable for <code>swiz</code> getter/setter.
		 */
		private var _swiz:Swiz;
		
		public function AutowiredTestCase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * Setter for beanProvider property.
		 */
		public function set beanProviders(beanProviders:Array):void
		{
			_beanProviders = beanProviders;
		}
		
		
		/**
		 * Getter for beanProvider property.
		 */
		public function get beanProviders():Array
		{
			return _beanProviders;
		}
		
		/**
		 * Setter for swizConfig property.
		 */
		public function set swizConfig(swizConfig:SwizConfig):void
		{
			_swizConfig = swizConfig;
		}
		
		
		/**
		 * Getter for swizConfig property.
		 */
		public function get swizConfig():SwizConfig
		{
			return _swizConfig;
		}
		
		/**
		 * Getter for local Swiz instance.
		 */
		public function get swiz():Swiz
		{
			return _swiz;
		}
		
		/**
		 * 
		 */ 
		[Before]
		public function constructSwizContext():void
		{
			
			trace("constructSwizContext() called");
			
			// initialize bean factory with configurec bean provider
			if( _swiz == null && _beanProviders != null )
			{
				_swiz = new Swiz(null, _swizConfig, null, _beanProviders);
				_swiz.init();
				
				// wrap the unit test in a Bean definition
				var bean:Bean = new Bean();
				bean.source = this;
				bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, _swiz.domain );
				
				// autowire test case with bean factory
				_swiz.beanFactory.setUpBean( bean );
			}
		}
	
	}
}