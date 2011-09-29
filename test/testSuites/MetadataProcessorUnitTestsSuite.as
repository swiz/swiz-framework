package testSuites
{
	import org.swizframework.processors.BaseMetadataProcessorTest;
	import org.swizframework.processors.DispatcherProcessorTest;
	import org.swizframework.processors.EventHandlerProcessorTest;
	import org.swizframework.processors.InjectProcessorTest;
	import org.swizframework.processors.PostConstructProcessorTest;
	import org.swizframework.processors.PreDestroyProcessorTest;
	import org.swizframework.processors.SwizInterfaceProcessorTest;
	import org.swizframework.processors.ViewProcessorTest;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MetadataProcessorUnitTestsSuite
	{
		public var test1:BaseMetadataProcessorTest;
		
		public var test2:DispatcherProcessorTest;
		
		public var test3:EventHandlerProcessorTest;
		
		public var test4:InjectProcessorTest;
		
		public var test5:PostConstructProcessorTest;
		
		public var test6:PreDestroyProcessorTest;
		
		public var test7:SwizInterfaceProcessorTest;
		
		public var test8:ViewProcessorTest;
	}
}