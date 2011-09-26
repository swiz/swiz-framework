package testSuites
{
	import testSuites.MetadataProcessorUnitTestsSuite;
	import testSuites.ReflectionUnitTestsSuite;
	import testSuites.StorageUnitTestsSuite;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class AllUnitTestsSuite
	{
		public var test1:MetadataProcessorUnitTestsSuite;
		public var test2:ReflectionUnitTestsSuite;
		public var test3:StorageUnitTestsSuite;
		
	}
}