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
	import org.swizframework.metadata.PostConstructMetadataTag;
	import org.swizframework.reflection.IMetadataTag;

	public class PostConstructProcessorTest
	{		
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var bean:Bean;
		
		private var processor:PostConstructProcessor;
		
		private var metadataTagHelper:MetadataTagHelper;
		
		private var beanSource:PostConstructHelper;
		
		[Before]
		public function setUp():void
		{
			processor = new PostConstructProcessor(["PostConstruct"]);
			metadataTagHelper = new MetadataTagHelper();
			
			beanSource = new PostConstructHelper();
			stub(bean).getter("source").returns(beanSource);
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (No ordering)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTags_onePostConstructMetadataTag_invokesFunction():void
		{
			// [PostConstruct] public function someFunction():void {...}
			var tag:IMetadataTag = createPostConstructMetadataTag({}, "doThis");
			processor.setUpMetadataTags([tag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.doThis)));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (ordering)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTags_onePostConstructMetadataTagWithOrdering_invokesFunction():void
		{
			// [PostConstruct(order="1")] public function someFunction():void {...}
			var tag:IMetadataTag = createPostConstructMetadataTag({"order":"1"}, "doThis");
			processor.setUpMetadataTags([tag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.doThis)));
		}
		
		[Test]
		public function setUpMetadataTags_twoPostConstructMetadataTagWithOrdering_invokesBothFunctions():void
		{
			// [PostConstruct(order="1")] public function someFunction():void {...}
			// [PostConstruct(order="2")] public function someOtherFunction():void {...}
			var firstTag:IMetadataTag = createPostConstructMetadataTag({"order":"1"}, "doThis");
			var secondTag:IMetadataTag = createPostConstructMetadataTag({"order":"2"}, "thenDoThis");
			processor.setUpMetadataTags([firstTag, secondTag], bean);
			assertThat(beanSource.invokedFunctions, arrayWithSize(2));
		}
		
		[Test]
		public function setUpMetadataTags_twoPostConstructMetadataTagWithOrdering_invokesBothFunctionsInProperOrder():void
		{
			// [PostConstruct(order="2")] public function someFunction():void {...}
			// [PostConstruct(order="1")] public function someOtherFunction():void {...}
			var firstTag:IMetadataTag = createPostConstructMetadataTag({"order":"2"}, "doThis");
			var secondTag:IMetadataTag = createPostConstructMetadataTag({"order":"1"}, "thenDoThis");
			processor.setUpMetadataTags([firstTag, secondTag], bean);
			assertThat(beanSource.invokedFunctions, array(strictlyEqualTo(beanSource.thenDoThis), strictlyEqualTo(beanSource.doThis)));
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous test helper function(s)
		//
		//------------------------------------------------------
		
		private function createPostConstructMetadataTag(args:Object, methodName:String):PostConstructMetadataTag
		{
			var tag:IMetadataTag = metadataTagHelper.createBaseMetadataTagWithArgs("PostConstruct", args, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, methodName);
			var postConstructTag:PostConstructMetadataTag = new PostConstructMetadataTag();
			postConstructTag.copyFrom(tag);
			
			return postConstructTag;
		}
	}
}

class PostConstructHelper
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