package org.swizframework.processors
{
	import helpers.metadata.MetadataTagHelper;
	
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.object.strictlyEqualTo;
	import org.swizframework.core.Bean;
	import org.swizframework.metadata.PreDestroyMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	
	public class PreDestroyProcessorTest
	{		
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var bean:Bean;
		
		private var processor:PreDestroyProcessor;
		
		private var metadataTagHelper:MetadataTagHelper;
		
		private var beanSource:PreDestroyHelper;
		
		[Before]
		public function setUp():void
		{
			processor = new PreDestroyProcessor(["PreDestroy"]);
			metadataTagHelper = new MetadataTagHelper();
			
			beanSource = new PreDestroyHelper();
			stub(bean).getter("source").returns(beanSource);
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (No ordering)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTags_onePreDestroyMetadataTag_invokesFunction():void
		{
			// [PreDestroy] public function someFunction():void {...}
			var tag:IMetadataTag = createPreDestroyMetadataTag({}, "doThis");
			processor.tearDownMetadataTags([tag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.doThis)));
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (ordering)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTags_onePreDestroyMetadataTagWithOrdering_invokesFunction():void
		{
			// [PreDestroy(order="1")] public function someFunction():void {...}
			var tag:IMetadataTag = createPreDestroyMetadataTag({"order":"1"}, "doThis");
			processor.tearDownMetadataTags([tag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.doThis)));
		}
		
		[Test]
		public function tearDownMetadataTags_twoPreDestroyMetadataTagsWithOrdering_invokesBothFunctions():void
		{
			// [PreDestroy(order="1")] public function someFunction():void {...}
			// [PreDestroy(order="2")] public function someOtherFunction():void {...}
			var firstTag:IMetadataTag = createPreDestroyMetadataTag({"order":"1"}, "doThis");
			var secondTag:IMetadataTag = createPreDestroyMetadataTag({"order":"2"}, "thenDoThis");
			processor.tearDownMetadataTags([firstTag, secondTag], bean);
			assertThat(beanSource.invokedFunctions, arrayWithSize(2));
		}
		
		[Test]
		public function tearDownMetadataTags_twoPostConstructMetadataTagsWithOrdering_invokesBothFunctionsInProperOrder():void
		{
			// [PreDestroy(order="2")] public function someFunction():void {...}
			// [PreDestroy(order="1")] public function someOtherFunction():void {...}
			var firstTag:IMetadataTag = createPreDestroyMetadataTag({"order":"2"}, "doThis");
			var secondTag:IMetadataTag = createPreDestroyMetadataTag({"order":"1"}, "thenDoThis");
			processor.tearDownMetadataTags([firstTag, secondTag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.thenDoThis), strictlyEqualTo(beanSource.doThis)));
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous test helper function(s)
		//
		//------------------------------------------------------
		
		private function createPreDestroyMetadataTag(args:Object, methodName:String):PreDestroyMetadataTag
		{
			var tag:IMetadataTag = metadataTagHelper.createBaseMetadataTagWithArgs("PreDestroy", args, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, methodName);
			var preDestroyTag:PreDestroyMetadataTag = new PreDestroyMetadataTag();
			preDestroyTag.copyFrom(tag);
			
			return preDestroyTag;
		}
	}
}

class PreDestroyHelper
{
	public var invokedFunctions:Array = [];
	
	public function doThis():void
	{
		invokedFunctions.push(doThis);
	}
	
	public function thenDoThis():void
	{
		invokedFunctions.push(thenDoThis);
	}
}