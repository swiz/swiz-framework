package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	
	public interface IBeanProcessor extends IProcessor
	{
		function setUpBean( bean:Bean ):void;
		
		function tearDownBean( bean:Bean ):void;
	}
}