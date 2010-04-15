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

package org.swizframework.utils
{
	import flash.system.ApplicationDomain;
	
	import mx.modules.Module;
	import mx.modules.ModuleManager;

	public class DomainUtil
	{
		/**
		 * Returns the domain used to load an object. Because of significant 
		 * issues in the Flex Framework, we will either use the ModuleManager or fall
		 * back on ApplicationDomain.currentDomain. This is because an object's loaderInfo
		 * may very well not have the correct domain associated with it when Swiz initializes.
		 */
		public static function getDomain( object:Object ):ApplicationDomain
		{
			var domain:ApplicationDomain = getModuleDomain( object );
			
			if( domain == null )
				domain = ApplicationDomain.currentDomain;

			return domain;
		}
		
		/**
		 * Returns the domain used to load an a module, only if the object supplied is a module. 
		 * Uses the ModuleManager to find the ApplicationDomain in the associated factory, which is a loader.
		 * Unfortunately this appears to be the only trustable method for finding a module's domain.
		 */
		public static function getModuleDomain( object:Object ):ApplicationDomain
		{
			if( object is Module )
			{
				var moduleInfo:Object = ModuleManager.getAssociatedFactory( object ).info();
				return moduleInfo.currentDomain;
			}
			else
			{
				return null;
			}
		}
	}
}