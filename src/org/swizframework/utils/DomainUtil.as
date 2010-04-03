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
		 * Returns the domain used to load an a module, only if the object supplied is in fact a module.
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