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

package org.swizframework.utils.services
{
	import mx.rpc.AsyncToken;
	
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;

	public class ServiceHelper implements IServiceHelper, ISwizAware
	{
		protected var _swiz:ISwiz;

		public function set swiz( swiz:ISwiz ):void
		{
			_swiz = swiz;
		}

		public function executeServiceCall( call:AsyncToken, resultHandler:Function, faultHandler:Function = null, handlerArgs:Array = null ):AsyncToken
		{
			// use default fault handler defined for swiz instance if not provided
			// check if swiz is set which is not the case if ServiceHelper is used in a testing environment
			if( faultHandler == null && _swiz != null && _swiz.config.defaultFaultHandler != null )
				faultHandler = _swiz.config.defaultFaultHandler;

			call.addResponder( new SwizResponder( resultHandler, faultHandler, handlerArgs ) );
			
			return call;
		}
	}
}