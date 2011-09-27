package testSuites
{
	import org.swizframework.processors.BaseMetadataProcessorTest;
	import org.swizframework.processors.DispatcherProcessorTest;
	import org.swizframework.processors.EventHandlerProcessorTest;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MetadataProcessorUnitTestsSuite
	{
		public var test1:BaseMetadataProcessorTest;
		
		public var test2:DispatcherProcessorTest;
		
		public var test3:EventHandlerProcessorTest;
	}
}