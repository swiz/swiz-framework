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

package org.swizframework.controller
{
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.rpc.AsyncToken;
	
	import org.swizframework.core.IDispatcherAware;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	import org.swizframework.utils.chain.AsyncCommandChainStep;
	import org.swizframework.utils.chain.ChainType;
	import org.swizframework.utils.chain.CommandChain;
	import org.swizframework.utils.services.SwizResponder;
	import org.swizframework.utils.services.SwizURLRequest;
	
	public class AbstractController implements ISwizAware, IDispatcherAware
	{
		public var _swiz:ISwiz;
		private var _dispatcher:IEventDispatcher;
		
		public function AbstractController()
		{
		}
		
		public function set swiz( swiz :ISwiz ):void
		{
			_swiz = swiz;
		}
		
		/** IDispatcherAware implementation */
		public function set dispatcher( dispatcher:IEventDispatcher ):void
		{
			_dispatcher = dispatcher;
		}
		
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		/** Delegates execute service call to Swiz */
		protected function executeServiceCall( call:AsyncToken, resultHandler:Function,
											   faultHandler:Function = null, handlerArgs:Array = null ):AsyncToken
		{
			
			if( faultHandler == null && _swiz.config.defaultFaultHandler != null )
				faultHandler = _swiz.config.defaultFaultHandler;
			
			call.addResponder( new SwizResponder( resultHandler, faultHandler, handlerArgs ) );
			
			return call;
		}
		
		/** Delegates execute url request call to Swiz */
		protected function executeURLRequest( request:URLRequest, resultHandler:Function, faultHandler:Function = null,
											  progressHandler:Function = null, httpStatusHandler:Function = null,
											  handlerArgs:Array = null ):URLLoader
		{
			
			if( faultHandler == null && _swiz.config.defaultFaultHandler != null )
				faultHandler = _swiz.config.defaultFaultHandler;
			
			return new SwizURLRequest( request, resultHandler, faultHandler, progressHandler, httpStatusHandler, handlerArgs ).loader;
		}
		
		/** Delegates create command to Swiz */
		protected function createCommand( delayedCall:Function, args:Array, resultHandler:Function,
										  faultHandler:Function = null, handlerArgs:Array = null ):AsyncCommandChainStep
		{
			return new AsyncCommandChainStep( delayedCall, args, resultHandler, faultHandler, handlerArgs );
		}
		
		/** Constructs a dynamic command */
		public function createChain( mode:String = ChainType.SEQUENCE ):CommandChain
		{
			return new CommandChain( mode );
		}
	}
}