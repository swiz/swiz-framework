package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	
	public interface IBeanProcessor extends IProcessor
	{
		
		function addBean( bean:Bean ):void;
		
		function removeBean( bean:Bean ):void;
		
	}
}