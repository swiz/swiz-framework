package org.swizframework.utils
{
	CONFIG::flex4
	{
		import mx.modules.IModule;
	}
	
	CONFIG::flex3
	{
		import mx.modules.Module;
	}

	public class ModuleTypeUtil
	{
		CONFIG::flex4
		{
			public static const MODULE_TYPE:Class = IModule
		}
		
		CONFIG::flex3
		{
			public static const MODULE_TYPE:Class = Module;
		}
	}
}