package org.swizframework.processors
{
	import helpers.metadata.MetadataTag;
	import helpers.metadata.NullMetadataProcessor;
	
	import mockolate.runner.MockolateRule;
	
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.IMetadataTag;

	public class BaseMetadataProcessorTest
	{	
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var firstMetadataTag:IMetadataTag;
		
		[Mock]
		public var secondMetadataTag:IMetadataTag;
		
		[Mock]
		public var bean:Bean;
		
		private var processor:BaseMetadataProcessor;
		
		[Before]
		public function setUp():void
		{
			processor = new NullMetadataProcessor(["MyFirstMetadataName", "MySecondMetadataName"]);
		}
		
		//------------------------------------------------------
		//
		// setupMetadataTags tests
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTags_noMetadataClassPassedToConstructorAndOneMetadataTag_invokesSetupMetadataTagOnce():void
		{
			processor.setUpMetadataTags([firstMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).setupMetadataTagInvocationCount, equalTo(1));
		}
		
		[Test]
		public function setUpMetadataTags_noMetadataClassPassedToConstructorAndMultipleMetadataTags_invokesSetupMetadataTagOnceForEachTag():void
		{
			processor.setUpMetadataTags([firstMetadataTag, secondMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).setupMetadataTagInvocationCount, equalTo(2));
		}
		
		[Test]
		public function setUpMetadataTags_metadataClassPassedToConstructor_replacesMetadataTagArrayElementWithCorrectMetadataTagInstance():void
		{
			processor = new NullMetadataProcessor(["MyFirstMetadataName", "MySecondMetadataName"], MetadataTag);
			var tags:Array = [firstMetadataTag];
			processor.setUpMetadataTags(tags, bean);
			assertThat(tags, array(isA(MetadataTag)));
		}
		
		//------------------------------------------------------
		//
		// validateMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test]
		public function validateMetadataTags_noMetadataClassPassedToConstructorAndOneMetadataTag_doesNotInvokeValidateMetadataTag():void
		{
			processor.setUpMetadataTags([firstMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).validateMetadataTagInvocationCount, equalTo(0));
		}
		
		[Test]
		public function validateMetadataTags_noMetadataClassPassedToConstructorAndMultipleMetadataTags_doesNotInvokeValidateMetadataTag():void
		{
			processor.setUpMetadataTags([firstMetadataTag, secondMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).validateMetadataTagInvocationCount, equalTo(0));
		}
		
		[Test]
		public function validateMetadataTags_metadataClassPassedToConstructorAndOneMetadataTag_invokesValidateMetadataTagOnce():void
		{
			processor = new NullMetadataProcessor(["MyFirstMetadataName"], MetadataTag);
			var tags:Array = [firstMetadataTag];
			processor.setUpMetadataTags(tags, bean);
			assertThat(NullMetadataProcessor(processor).validateMetadataTagInvocationCount, equalTo(1));
		}
		
		[Test]
		public function validateMetadataTags_metadataClassPassedToConstructorAndTwoMetadataTags_invokesValidateMetadataTagTwice():void
		{
			processor = new NullMetadataProcessor(["MyFirstMetadataName", "MySecondMetadataName"], MetadataTag);
			var tags:Array = [firstMetadataTag, secondMetadataTag];
			processor.setUpMetadataTags(tags, bean);
			assertThat(NullMetadataProcessor(processor).validateMetadataTagInvocationCount, equalTo(2));
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTags tests
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTags_noMetadataClassPassedToConstructorAndOneMetadataTag_invokesTearDownMetadataTagOnce():void
		{
			processor.tearDownMetadataTags([firstMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).tearDownMetadataTagInvocationCount, equalTo(1));
		}
		
		[Test]
		public function tearDownMetadataTags_noMetadataClassPassedToConstructorAndMultipleMetadataTags_invokesTearDownMetadataTagOnceForEachTag():void
		{
			processor.tearDownMetadataTags([firstMetadataTag, secondMetadataTag], bean);
			assertThat(NullMetadataProcessor(processor).tearDownMetadataTagInvocationCount, equalTo(2));
		}
		
		[Test]
		public function tearDownMetadataTags_metadataClassPassedToConstructor_replacesMetadataTagArrayElementWithCorrectMetadataTagInstance():void
		{
			processor = new NullMetadataProcessor(["MyFirstMetadataName", "MySecondMetadataName"], MetadataTag);
			var tags:Array = [firstMetadataTag];
			processor.tearDownMetadataTags(tags, bean);
			assertThat(tags, array(isA(MetadataTag)));
		}
	}
}