package org.swizframework.processors
{
	import flash.events.IEventDispatcher;
	
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.strictlyEqualTo;
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;

	public class DispatcherProcessorTest
	{	
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var metadataTag:IMetadataTag;;
		
		[Mock]
		public var swiz:ISwiz;
		
		[Mock]
		public var metadataHost:IMetadataHost;
		
		[Mock]
		public var bean:Bean;
		
		[Mock]
		public var globalDispatcher:IEventDispatcher;
		
		[Mock]
		public var localDispatcher:IEventDispatcher;
		
		private var processor:DispatcherProcessor;
		
		private var beanSource:Object;
		
		private var swizConfig = new SwizConfig();
		
		private var metadataArg:MetadataArg;
		
		[Before]
		public function setUp():void
		{
			processor = new DispatcherProcessor(["Dispatcher"]);
			
			beanSource = new Object();
			stub(bean).getter("source").returns(beanSource);
			
			stub(swiz).getter("globalDispatcher").returns(globalDispatcher);
			stub(swiz).getter("dispatcher").returns(localDispatcher);
			stub(swiz).getter("config").returns(swizConfig);
			
			processor.init(swiz);
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_scopeIsGlobal_setsDispatcherToGlobalDispatcher():void
		{
			// Test: [Dispatcher(scope="global")]
			metadataArg = new MetadataArg("scope", SwizConfig.GLOBAL_DISPATCHER);
			setupMetadataTag(SwizConfig.GLOBAL_DISPATCHER);
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(globalDispatcher));
		}
		
		[Test]
		public function setUpMetadataTag_scopeIsLocal_setsDispatcherToLocalDispatcher():void
		{
			// Test: [Dispatcher(scope="local")]
			metadataArg = new MetadataArg("scope", SwizConfig.LOCAL_DISPATCHER);
			setupMetadataTag(SwizConfig.LOCAL_DISPATCHER);
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(localDispatcher));
		}
		
		[Test]
		public function setUpMetadataTag_defaultArgumentScopeIsGlobal_setsDispatcherToGlobalDispatcher():void
		{
			// Test: [Dispatcher("global")]
			metadataArg = new MetadataArg("", SwizConfig.GLOBAL_DISPATCHER);
			setupMetadataTag(null, [metadataArg]);
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(globalDispatcher));
		}
		
		[Test]
		public function setUpMetadataTag_defaultArgumentScopeIsLocal_setsDispatcherToLocalDispatcher():void
		{
			// Test: [Dispatcher("local")]
			metadataArg = new MetadataArg("", SwizConfig.LOCAL_DISPATCHER);
			setupMetadataTag(null, [metadataArg]);
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(localDispatcher));
		}
		
		[Test]
		public function setUpMetadataTag_metadataTagHasNoScopeArgumentAndSwizConfigDefaultDispatcherIsGlobal_setsDispatcherToGlobalDispatcher():void
		{
			// Test: [Dispatcher]
			setupMetadataTag();
			swizConfig.defaultDispatcher = SwizConfig.GLOBAL_DISPATCHER;
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(globalDispatcher));
		}
		
		[Test]
		public function setUpMetadataTag_metadataTagHasNoScopeArgumentAndSwizConfigDefaultDispatcherIsLocal_setsDispatcherToLocalDispatcher():void
		{
			// Test: [Dispatcher]
			setupMetadataTag();
			swizConfig.defaultDispatcher = SwizConfig.LOCAL_DISPATCHER;
			processor.setUpMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, strictlyEqualTo(localDispatcher));
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_setsBeanSourceDispatcherToNull():void
		{
			setupMetadataTag();
			beanSource.dispatcher = globalDispatcher;
			processor.tearDownMetadataTag(metadataTag, bean);
			assertThat(beanSource.dispatcher, nullValue());
		}
		
		//------------------------------------------------------
		//
		// Test helper function(s)
		//
		//------------------------------------------------------
		
		
		private function setupMetadataTag(scope:String = null, metadataArgs:Array = null):void
		{
			stub(metadataHost).getter("name").returns("dispatcher");
			stub(metadataTag).getter("host").returns(metadataHost);

			stub(metadataTag).method("hasArg").args(equalTo("scope")).returns(scope != null);
			stub(metadataTag).method("getArg").args(equalTo("scope")).returns(metadataArg);
			stub(metadataTag).getter("args").returns(metadataArgs ? metadataArgs : []);
		}
		
	}
}