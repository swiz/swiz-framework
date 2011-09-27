package org.swizframework.processors
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	
	import helpers.metadata.MetadataTagHelper;
	
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.metadata.EventHandlerMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;

	public class EventHandlerProcessorTest
	{	
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var swiz:ISwiz;
		
		[Mock]
		public var bean:Bean;
		
		[Mock]
		public var globalDispatcher:IEventDispatcher;
		
		[Mock]
		public var localDispatcher:IEventDispatcher;
		
		private var processor:EventHandlerProcessor;
		
		private var swizConfig:SwizConfig;
		
		private var metadataTagHelper:MetadataTagHelper;
		
		private var beanSource:Object;
		
		[Before]
		public function setUp():void
		{
			processor = new EventHandlerProcessor(["EventHandler", "Mediate"]);
			metadataTagHelper = new MetadataTagHelper();
			
			beanSource = new Object();
			beanSource["someFunction"] = new Function();
			stub(bean).getter("source").returns(beanSource);
			
			swizConfig = new SwizConfig();
			swizConfig.eventPackages = [];
			swizConfig.defaultDispatcher = SwizConfig.GLOBAL_DISPATCHER;
			
			stub(swiz).getter("globalDispatcher").returns(globalDispatcher);
			stub(swiz).getter("dispatcher").returns(localDispatcher);
			stub(swiz).getter("config").returns(swizConfig);
			stub(swiz).getter("domain").returns(ApplicationDomain.currentDomain);
			
			processor.init(swiz);
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_noEventArgumentOnTag_throwsError():void
		{
			// [EventHandler]
			var tag:IMetadataTag = createEventHandlerMetadataTag({});
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test(expects="Error")]
		public function setUpMetadataTag_eventArgumentReferencesUnqualifiedClassNotInAnyEventsPackages_throwsError():void
		{
			// [EventHandler(event="SomeEvent.SOME_TYPE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"SomeEvent.SOME_TYPE"});
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test(expects="Error")]
		public function setUpMetadataTag_eventArgumentReferencesValidQualifiedClassWithNonExistantType_throwsError():void
		{
			// [EventHandler("event="flash.events.Event.SOME_TYPE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.SOME_TYPE"});
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test(expects="Error")]
		public function setUpMetadataTag_eventArgumentReferencesValidUnqualifiedClassInEventPackageWithNonExistantType_throwsError():void
		{
			// [EventHandler(event="Event.SOME_TYPE")]
			swizConfig.eventPackages = ["flash.events.*"];
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"Event.SOME_TYPE"});
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_defaultSwizDispatcherIsLocalAndNoScopeMetadataTagArgument_addsEventListenerToLocalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			swizConfig.defaultDispatcher = SwizConfig.LOCAL_DISPATCHER;
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(localDispatcher).method("addEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_defaultSwizDispatcherIsGlobalAndNoScopeMetadataTagArgument_addsEventListenerToGlobalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(globalDispatcher).method("addEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_scopeMetadataTagArgumentIsLocal_addsEventListenerToLocalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", scope="local")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "scope":SwizConfig.LOCAL_DISPATCHER});
			mock(localDispatcher).method("addEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_scopeMetadataTagArgumentIsGlobal_addsEventListenerToGlobalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", scope="global")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "scope":SwizConfig.GLOBAL_DISPATCHER});
			mock(globalDispatcher).method("addEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_noOtherMetadataArgs_addsEventListenerWithCorrectArguments():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(globalDispatcher).method("addEventListener").args(equalTo(Event.COMPLETE), isA(Function), isFalse(), equalTo(0), isTrue()).once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		[Test]
		public function setUpMetadataTag_allMetadataArgsSpecified_addsEventListenerWithCorrectArguments():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", useCapture="true", priority="72")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "useCapture":"true", "priority":"72"});
			mock(globalDispatcher).method("addEventListener").args(equalTo(Event.COMPLETE), isA(Function), isTrue(), equalTo(72), isTrue()).once();
			processor.setUpMetadataTag(tag, bean);
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_defaultSwizDispatcherIsLocalAndNoScopeMetadataTagArgument_removesEventListenerFromLocalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			swizConfig.defaultDispatcher = SwizConfig.LOCAL_DISPATCHER;
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(localDispatcher).method("removeEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		[Test]
		public function tearDownMetadataTag_defaultSwizDispatcherIsGlobalAndNoScopeMetadataTagArgument_removesEventListenerFromGlobalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(globalDispatcher).method("removeEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		[Test]
		public function tearDownMetadataTag_scopeMetadataTagArgumentIsLocal_removesEventListenerFromLocalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", scope="local")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "scope":SwizConfig.LOCAL_DISPATCHER});
			mock(localDispatcher).method("removeEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		[Test]
		public function tearDownMetadataTag_scopeMetadataTagArgumentIsGlobal_removesEventListenerFromGlobalDispatcher():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", scope="global")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "scope":SwizConfig.GLOBAL_DISPATCHER});
			mock(globalDispatcher).method("removeEventListener").anyArgs().once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		[Test]
		public function tearDownMetadataTag_noOtherMetadataArgs_removesEventListenerWithCorrectArguments():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE"});
			mock(globalDispatcher).method("removeEventListener").args(equalTo(Event.COMPLETE), isA(Function), isFalse()).once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		[Test]
		public function tearDownMetadataTag_allMetadataArgsSpecified_removesEventListenerWithCorrectArguments():void
		{
			// [EventHandler(event="flash.events.Event.COMPLETE", useCapture="true", priority="72")]
			var tag:IMetadataTag = createEventHandlerMetadataTag({"event":"flash.events.Event.COMPLETE", "useCapture":"true", "priority":"72"});
			mock(globalDispatcher).method("removeEventListener").args(equalTo(Event.COMPLETE), isA(Function), isTrue()).once();
			processor.setUpMetadataTag(tag, bean);
			processor.tearDownMetadataTag(tag, bean);
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous test helper function(s)
		//
		//------------------------------------------------------
		
		private function createEventHandlerMetadataTag(args:Object):EventHandlerMetadataTag
		{
			var tag:IMetadataTag = metadataTagHelper.createBaseMetadataTagWithArgs("EventHandler", args, "method", "someFunction");
			var eventHandlerTag:EventHandlerMetadataTag = new EventHandlerMetadataTag();
			eventHandlerTag.copyFrom(tag);
			
			return eventHandlerTag;
		}
		
	}
}