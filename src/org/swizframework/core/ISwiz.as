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
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	/**
	 * Swiz Interface
	 */
	public interface ISwiz
	{
		// ========================================
		// public properties
		// ========================================
		
		function get catchViews():Boolean;
		function set catchViews( value:Boolean ):void;
		
		/**
		 * Local Dispatcher
		 */
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;
		
		/**
		 * Global Dispatcher
		 */
		function get globalDispatcher():IEventDispatcher;
		function set globalDispatcher( value:IEventDispatcher ):void;
		
		/**
		 * Domain
		 */
		function get domain():ApplicationDomain;
		function set domain( value:ApplicationDomain ):void;
		
		/**
		 * Config
		 */
		function get config():ISwizConfig;
		function set config( value:ISwizConfig ):void;
		
		[ArrayElementType( "org.swizframework.core.IBeanProvider" )]
		
		/**
		 * Bean Providers
		 */
		function get beanProviders():Array;
		function set beanProviders( value:Array ):void;
		
		/**
		 * Bean Factory
		 */
		function get beanFactory():IBeanFactory;
		function set beanFactory( value:IBeanFactory ):void;
		
		[ArrayElementType( "org.swizframework.processors.IProcessor" )]
		
		/**
		 * Processors
		 */
		function get processors():Array;
		
		/**
		 * Custom Processors
		 */
		function set customProcessors( value:Array ):void;
		
		/**
		 * Parent Swiz instance, for nesting and modules
		 */
		function get parentSwiz():ISwiz;
		function set parentSwiz( parentSwiz:ISwiz ):void;
		
		[ArrayElementType( "org.swizframework.utils.logging.AbstractSwizLoggingTarget" )]
		
		/**
		 * Logging targets
		 */
		function get loggingTargets():Array;
		function set loggingTargets( value:Array ):void;
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called once in initialize Swiz
		 */
		function init():void;
		
		/**
		 * Clean up this Swiz instance
		 */
		function tearDown():void;
		
		/**
		 * Register a new window with Swiz so that its metadata can be processed.
		 */ 
		function registerWindow( window:IEventDispatcher, windowSwiz:ISwiz = null ):void;
	}
}