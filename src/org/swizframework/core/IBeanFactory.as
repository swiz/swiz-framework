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
	import flash.utils.Dictionary;

	/**
	 * Bean Factory Interface
	 */
	public interface IBeanFactory
	{
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called by Swiz
		 */
		function init( swiz:ISwiz ):void;
		function setUpBeans():void;
		function setUpBean( bean:Bean ):void;
		
		function createBean( target:Object, beanName:String = null ):Bean;
		function addBean( bean:Bean ):Bean;
		
		/**
		 * Parent Swiz instance, for nesting and modules
		 */
		function get parentBeanFactory():IBeanFactory;
		function set parentBeanFactory( parentBeanFactory:IBeanFactory ):void;
		
		/**
		 * Maybe better to extend bean provider interface
		 */
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
		
		function get beans():Dictionary;
		
		function tearDownBeans():void;
		function tearDownBean( bean:Bean ):void;
	}
}