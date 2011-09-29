package org.swizframework.processors
{
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	
	import helpers.metadata.MetadataTagHelper;
	
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.flexunit.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.strictlyEqualTo;
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanFactory;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.metadata.InjectMetadataTag;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	import org.swizframework.utils.services.IServiceHelper;
	import org.swizframework.utils.services.IURLRequestHelper;
	import org.swizframework.utils.services.MockDelegateHelper;
	import org.swizframework.utils.services.ServiceHelper;
	import org.swizframework.utils.services.URLRequestHelper;

	public class InjectProcessorTest
	{		
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var beanFactory:IBeanFactory;
		
		[Mock]
		public var swiz:ISwiz;
		
		[Mock]
		public var sourceBean:Bean;
		
		[Mock]
		public var injectTargetBean:Bean;
		
		[Mock]
		public var injectTargetHelperBean:Bean;
		
		private var processor:InjectProcessor;
		
		private var swizConfig:SwizConfig;
		
		private var metadataTagHelper:MetadataTagHelper;
		
		private var beanSource:SomeImportantThing;
		
		private var injectTargetSource:Object;
		
		private var injectTargetHelperSource:InjectTargetHelper;
		
		[Before]
		public function setUp():void
		{
			processor = new InjectProcessor(["Inject", "Autowire"]);
			metadataTagHelper = new MetadataTagHelper();
			
			beanSource = new SomeImportantThing();
			stub(sourceBean).getter("source").returns(beanSource);
			
			injectTargetSource = new Object();
			stub(injectTargetBean).getter("source").returns(injectTargetSource);
			
			injectTargetHelperSource = new InjectTargetHelper();
			stub(injectTargetHelperBean).getter("source").returns(injectTargetHelperSource);
			
			swizConfig = new SwizConfig();
			swizConfig.defaultDispatcher = SwizConfig.GLOBAL_DISPATCHER;
			
			stub(swiz).getter("config").returns(swizConfig);
			stub(swiz).getter("beanFactory").returns(beanFactory);
			stub(swiz).getter("domain").returns(ApplicationDomain.currentDomain);
			
			processor.init(swiz);
		}
		
		//------------------------------------------------------
		//
		// validateMetadataTag tests
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function validateMetadataTag_basicInjectTagWithDestinationAnnotatingPublicProperty_throwsError():void
		{
			// [Inject(destination="someProperty"] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"someProperty"}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTags([tag], injectTargetBean);
		}
		
		[Test(expects="Error")]
		public function validateMetadataTag_basicInjectTagWithDestinationAnnotatingPublicSetter_throwsError():void
		{
			// [Inject(destination="someProperty"] public function setSomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"someProperty"}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTags([tag], injectTargetBean);
		}
		
		public function validateMetadataTag_basicInjectTagWithDestinationAnnotatingClass_doesNotThrowError():void
		{
			// [Inject(destination="someProperty"] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"someProperty"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "SomeClass", SomeImportantThing);
			processor.setUpMetadataTags([tag], injectTargetBean);
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by type into property)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagAnnotatingPublicPropertyAndNoBeanFound_throwsError():void
		{
			// [Inject] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithRequiredFalseAnnotatingPublicPropertyAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(required="false")] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({"required":"false"}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.mySomeImportantThing, strictlyEqualTo(beanSource));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndInjectingServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public var myService:ServiceHelper;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "myService", ServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.myService, isA(ServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndInjectingIServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public var myService:IServiceHelper;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "myService", IServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.myService, isA(IServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndInjectingURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public var myURLRequest:URLRequestHelper;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "myURLRequest", URLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.myURLRequest, isA(URLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndInjectingIURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public var myURLRequest:IURLRequestHelper;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "myURLRequest", IURLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.myURLRequest, isA(IURLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicPropertyAndInjectingMockDelegateHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public var myDelegate:MockDelegateHelper;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "myDelegate", MockDelegateHelper);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.myDelegate, isA(MockDelegateHelper));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by type into setter function)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagAnnotatingPublicSetterAndNoBeanFound_throwsError():void
		{
			// [Inject] public function setSomeImportantThing(newValue:SomeImportantThing):void {...}
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithRequiredFalseAnnotatingPublicSetterAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(required="false")] public function setSomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({"required":"false"}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject] public function setSomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, strictlyEqualTo(beanSource));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndInjectingServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public function setMyService(newValue:ServiceHelper):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setMyService", ServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(ServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndInjectingIServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public function setMyService(newValue:IServiceHelper):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setMyService", IServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(IServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndInjectingURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public function setMyURLRequest(newValue:URLRequestHelper):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setMyURLRequest", URLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(URLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndInjectingIURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public function setMyURLRequest(newValue:IURLRequestHelper):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setMyURLRequest", IURLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(IURLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingPublicSetterAndInjectingMockDelegateHelper_injectsSourceIntoTarget():void
		{
			// [Inject] public function setMyDelegate(neValue:MockDelegateHelper):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setMyMockDelegate", MockDelegateHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(MockDelegateHelper));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by type into property annotating the class and using the destination argument)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagAnnotatingClassAndNoBeanFound_throwsError():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...}
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithRequiredFalseAnnotatingClassAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(required="false", destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"required":"false", "destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, strictlyEqualTo(beanSource));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndInjectingServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMyService", ServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(ServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndInjectingIServiceHelper_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMyService", IServiceHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(IServiceHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndInjectingURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMyURLRequest", URLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(URLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndInjectingIURLRequestHelper_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMyURLRequest", IURLRequestHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(IURLRequestHelper));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassAndInjectingMockDelegateHelper_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "setMyMockDelegate", MockDelegateHelper);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, isA(MockDelegateHelper));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by type into nested property annotating the class and using the destination argument)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_injectTagAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(destination="somePublicProperty.someNestedPublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"destination":"somePublicProperty.mySomeImportantThing"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.somePublicProperty.mySomeImportantThing, strictlyEqualTo(beanSource));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name into property)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagWithSourceAnnotatingPublicPropertyAndNoBeanFound_throwsError():void
		{
			// [Inject(source="someSource"] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource"}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndRequiredFalseAnnotatingPublicPropertyAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(source="someSource", required="false")] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "required":"false"}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAnnotatingPublicPropertyAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(source="someSource"] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource"}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.mySomeImportantThing, strictlyEqualTo(beanSource));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name into setter function)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagWithSourceAnnotatingPublicSetterAndNoBeanFound_throwsError():void
		{
			// [Inject(source="someSource"] public function setMySomeImportantThing(newValue:SomeImportantThing):void {...}
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource"}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndRequiredFalseAnnotatingPublicSetterAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(source="someSource", required="false")] public function setMySomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "required":"false"}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAnnotatingPublicSetterAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(source="someSource"] public function setMySomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource"}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, strictlyEqualTo(beanSource));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name into property annotating the class and using the destination argument)
		//
		//------------------------------------------------------
		
		[Test(expects="Error")]
		public function setUpMetadataTag_basicInjectTagWithSourceAnnotatingClassAndNoBeanFound_throwsError():void
		{
			// [Inject(source="someSource", destination="somePublicProperty")] public class SomeClass {...}
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndRequiredFalseAnnotatingClassAndNoBeanFound_doesNotThrowError():void
		{
			// [Inject(source="someSource", required="false", destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "required":"false", "destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			processor.setUpMetadataTag(tag, injectTargetBean);
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAnnotatingClassAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(source="someSource", destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, strictlyEqualTo(beanSource));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name into nested property annotating the class and using the destination argument)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(source="someSource", destination="somePublicProperty.someNestedPublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "destination":"somePublicProperty.mySomeImportantThing"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.somePublicProperty.mySomeImportantThing, strictlyEqualTo(beanSource));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name using property chain into nested property annotating the class and using the destination argument)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourcePropertyChainAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_injectsSourceIntoTarget():void
		{
			// [Inject(source="someSource.someProperty.someProperty", destination="somePublicProperty.someNestedPublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someProperty", "destination":"somePublicProperty.mySomeImportantThing"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.somePublicProperty.mySomeImportantThing, strictlyEqualTo(beanSource.someProperty));
		}
		
		//------------------------------------------------------
		//
		// setUpMetadataTag tests (inject by name using property chain into nested property annotating the class, using the destination argument and specifying bind)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndBindingAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_addsEventListenerToBindableSource():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(beanSource.addEventListenerInvocationCount, equalTo(1));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndBindingAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_doesNotAddEventListenerToBindableTarget():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true"] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.addEventListenerInvocationCount, equalTo(0));
		}
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourceAndTwoWayBindingAnnotatingClassInjectingIntoNestedDestinationAndBeanFound_addsEventListenerToBindableTarget():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true", twoWay="true"] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true", "twoWay":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.addEventListenerInvocationCount, equalTo(1));
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (injected by type into property)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_injectTagAnnotatingPublicProperty_nullsTarget():void
		{
			// [Inject] public var mySomeImportantThing:SomeImportantThing;
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_PROPERTY, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetBean);
			processor.tearDownMetadataTag(tag, injectTargetBean);
			assertThat(injectTargetSource.mySomeImportantThing, nullValue());
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (injected by type using setter)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_injectTagAnnotatingPublicSetter_nullsTarget():void
		{
			// [Inject] public function setSomeImportantThing(newValue:SomeImportantThing):void {...};
			var tag:IMetadataTag = createInjectMetadataTag({}, MetadataTagHelper.METADATA_HOST_TYPE_METHOD, "setSomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByType").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, nullValue());
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (injected by type using destination)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_injectTagWithSourceAnnotatingClass_nullsTarget():void
		{
			// [Inject(source="someSource", destination="somePublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource", "destination":"injectedBean"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.injectedBean, nullValue());
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (injected by name using destination)
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpMetadataTag_injectTagWithSourcePropertyChainAnnotatingClassInjectingIntoNestedDestination_nullsTarget():void
		{
			// [Inject(source="someSource.someProperty.someProperty", destination="somePublicProperty.someNestedPublicProperty")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someProperty", "destination":"somePublicProperty.mySomeImportantThing"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "mySomeImportantThing", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.somePublicProperty.mySomeImportantThing, nullValue());
		}
		
		//------------------------------------------------------
		//
		// tearDownMetadataTag tests (inject by name using property chain into nested property annotating the class, using the destination argument and specifying bind)
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownMetadataTag_injectTagWithSourceAndBindingAnnotatingClassInjectingIntoNestedDestination_removesEventListenerFromBindableSource():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true")] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(beanSource.removeEventListenerInvocationCount, equalTo(1));
		}
		
		[Test]
		public function tearDownMetadataTag_injectTagWithSourceAndBindingAnnotatingClassInjectingIntoNestedDestination_doesNotRemoveEventListenerFromBindableTarget():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true"] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.removeEventListenerInvocationCount, equalTo(0));
		}
		
		[Test]
		public function tearDownMetadataTag_injectTagWithSourceAndTwoWayBindingAnnotatingClassInjectingIntoNestedDestination_removesEventListenerFromBindableTarget():void
		{
			// [Inject(source="someSource.someProperty", destination="somePublicProperty", bind="true", twoWay="true"] public class SomeClass {...};
			var tag:IMetadataTag = createInjectMetadataTag({"source":"someSource.someBindableProperty", "destination":"someBindableProperty", "bind":"true", "twoWay":"true"}, MetadataTagHelper.METADATA_HOST_TYPE_CLASS, "someBindableProperty", SomeImportantThing);
			stub(beanFactory).method("getBeanByName").anyArgs().returns(sourceBean);
			processor.setUpMetadataTag(tag, injectTargetHelperBean);
			processor.tearDownMetadataTag(tag, injectTargetHelperBean);
			assertThat(injectTargetHelperSource.removeEventListenerInvocationCount, equalTo(1));
		}
		
		//------------------------------------------------------
		//
		// Miscellaneous test helper function(s)
		//
		//------------------------------------------------------
		
		private function createInjectMetadataTag(args:Object, metadataHostType:String = "property", hostName:String = null, hostType:Class = null):InjectMetadataTag
		{
			var tag:IMetadataTag = metadataTagHelper.createBaseMetadataTagWithArgs("Inject", args, metadataHostType, hostName, hostType);
			var injectTag:InjectMetadataTag = new InjectMetadataTag();
			injectTag.copyFrom(tag);
			
			if ( metadataHostType == MetadataTagHelper.METADATA_HOST_TYPE_METHOD )
			{
				createHostParameterForSetter(injectTag.host, hostType);
			}
			
			return injectTag;
		}
		
		private function createHostParameterForSetter(host:IMetadataHost, hostType:Class):void
		{
			var hostMethod:MetadataHostMethod = MetadataHostMethod(host);
			hostMethod.parameters.push(new MethodParameter(0, hostType, false));
		}
	}
}

import flash.events.EventDispatcher;

import org.swizframework.utils.services.IServiceHelper;
import org.swizframework.utils.services.IURLRequestHelper;
import org.swizframework.utils.services.MockDelegateHelper;
import org.swizframework.utils.services.ServiceHelper;
import org.swizframework.utils.services.URLRequestHelper;

/**
 * This helper class is used when testing inject against setter functions and 
 * class-annotations with destination and nested destination metadata arguments.
 */
class InjectTargetHelper extends EventDispatcher
{
	public var injectedBean:Object;
	
	public var somePublicProperty:Object = new Object();
	
	[Bindable]
	public var someBindableProperty:Object = new Object();
	
	public var addEventListenerInvocationCount:int;
	public var removeEventListenerInvocationCount:int;
	
	override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
	{
		addEventListenerInvocationCount += 1;
	}
	
	override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
	{
		removeEventListenerInvocationCount += 1;
	}
	
	public function setSomeImportantThing(newValue:SomeImportantThing):void
	{
		injectedBean = newValue;
	}
	
	public function setMyService(newValue:ServiceHelper):void
	{
		injectedBean = newValue;
	}
	
	public function setMyIService(newValue:IServiceHelper):void
	{
		injectedBean = newValue;
	}
	
	public function setMyURLRequest(newValue:URLRequestHelper):void
	{
		injectedBean = newValue;
	}
	
	public function setMyIURLRequest(newValue:IURLRequestHelper):void
	{
		injectedBean = newValue;
	}
	
	public function setMyMockDelegate(newValue:MockDelegateHelper):void
	{
		injectedBean = newValue;
	}
}

/**
 * The SomeImportantThing class is a simple class used as the bean source for many of the
 * tests. It has a public property which is used for testing inject by source where
 * the destination is a property chain.
 */
class SomeImportantThing extends EventDispatcher
{
	public var someProperty:Object = new Object();
	
	[Bindable]
	public var someBindableProperty:Object = new Object();
	
	public var addEventListenerInvocationCount:int;
	public var removeEventListenerInvocationCount:int;
	
	override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
	{
		addEventListenerInvocationCount += 1;
	}
	
	override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
	{
		removeEventListenerInvocationCount += 1;
	}
}