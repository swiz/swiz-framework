package org.swizframework.processors
{
	public interface IBeanProcessor extends IProcessor
	{
		
		function addBean( bean:Object ):void;
		
		function removeBean( bean:Object ):void;
		
	}
}