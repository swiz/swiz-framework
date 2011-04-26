/*
* Copyright 2010 Swiz Framework Contributors
* 
* Licensed under the Apache License, Version 2.0 (the "License"); you may not
* use this file except in compliance with the License. You may obtain a copy of
* the License. You may obtain a copy of the License at
* 
* http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations under
* the License.
*/
package org.swizframework.core
{
	import asx.array.forEach;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;
	
	import mx.events.FlexEvent;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.collection.hasItems;
	import org.swizframework.core.helpers.SomeOtherPresentationModel;
	import org.swizframework.core.helpers.SomePresentationModel;
	import org.swizframework.events.BeanEvent;
	import org.swizframework.events.SwizEvent;
	import org.swizframework.processors.IBeanProcessor;
	import org.swizframework.processors.IFactoryProcessor;
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.reflection.TypeDescriptor;

	public class BeanFactoryTest
	{
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		//---------------------------------------------------------------
		//
		// Mocks
		//
		//---------------------------------------------------------------
		
		[Mock]
		public var swiz:ISwiz;
		
		[Mock]
		public var parentSwiz:ISwiz;
		
		[Mock]
		public var dispatcher:IEventDispatcher;
		
		[Mock]
		public var parentDispatcher:IEventDispatcher;
		
		[Mock]
		public var beanProvider:IBeanProvider;
		
		[Mock]
		public var parentBeanProvider:IBeanProvider;
		
		[Mock]
		public var factoryProcessor:IFactoryProcessor;
		
		[Mock]
		public var metadataProcessor:IMetadataProcessor;
		
		[Mock]
		public var beanProcessor:IBeanProcessor;
		
		[Mock]
		public var newBeanProvider:IBeanProvider;
		
		//---------------------------------------------------------------
		//
		// Variables
		//
		//---------------------------------------------------------------
		private var beanFactory:BeanFactory;
		
		private var swizConfig:SwizConfig;
		
		private var parentBeanFactory:BeanFactory;
		
		private var parentSwizConfig:SwizConfig;
		
		//---------------------------------------------------------------
		//
		// SetUp
		//
		//---------------------------------------------------------------
		
		[Before]
		public function setUp():void
		{
			// Setup the bean factory
			beanFactory = new BeanFactory();
			swizConfig = new SwizConfig();
			stub(swiz).getter("dispatcher").returns(dispatcher);
			stub(swiz).getter("beanProviders").returns([beanProvider]);
			stub(swiz).getter("processors").returns([factoryProcessor, metadataProcessor, beanProcessor]);
			stub(swiz).getter("config").returns(swizConfig);
			stub(swiz).getter("domain").returns(ApplicationDomain.currentDomain);
			
			// Setup the parent bean factory
			parentBeanFactory = new BeanFactory();
			parentSwizConfig = new SwizConfig();
			stub(parentSwiz).getter("dispatcher").returns(parentDispatcher);
			stub(parentSwiz).getter("beanProviders").returns([parentBeanProvider]);
			stub(parentSwiz).getter("processors").returns([factoryProcessor, metadataProcessor, beanProcessor]);
			stub(parentSwiz).getter("config").returns(parentSwizConfig);
			stub(parentSwiz).getter("domain").returns(ApplicationDomain.currentDomain);
		}
		
		//---------------------------------------------------------------
		//
		// setUp tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function setUp_listensForAddBeanEvent():void
		{
			mock(dispatcher).method("addEventListener").args(BeanEvent.ADD_BEAN, Function).once();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_listensForSetupBeanEvent():void
		{
			mock(dispatcher).method("addEventListener").args(BeanEvent.SET_UP_BEAN, Function).once();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_listensForRemoveBeanEvent():void
		{
			mock(dispatcher).method("addEventListener").args(BeanEvent.REMOVE_BEAN, Function).once();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_listensForTeardownBeanEvent():void
		{
			mock(dispatcher).method("addEventListener").args(BeanEvent.TEAR_DOWN_BEAN, Function).once();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_singleBeanProviderWithBeans_setsBeans():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertThat(beanFactory.beans, arrayWithSize(1));
		}
		
		[Test]
		public function setUp_singleBeanProviderWithBeans_setsCorrectBeans():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function setUp_singleBeanProviderWithBeans_setsBeanFactoryOnBeans():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertStrictlyEquals("The beanFactory was not properly set on the bean.", beanFactory, bean.beanFactory);
		}
		
		[Test]
		public function setUp_singleBeanProviderWithPrototypeBeans_setsBeans():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertThat(beanFactory.beans, arrayWithSize(1));
		}
		
		[Test]
		public function setUp_singleBeanProviderWithPrototypeBeans_setsCorrectBeans():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function setUp_singleBeanProviderWithPrototypeBeans_setsBeanFactoryOnBeans():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertStrictlyEquals("The beanFactory was not properly set on the bean.", beanFactory, bean.beanFactory);
		}
		
		[Test]
		public function setUp_singleBeanProvider_runsFactoryProcessors():void
		{
			mock(factoryProcessor).method("setUpFactory").args(beanFactory).once();
			beanFactory.setUp(swiz);
			verify(factoryProcessor);
		}
		
		[Test]
		public function setUp_waitForSetupIsTrue_beansAreNotSetup():void
		{
			beanFactory.waitForSetup = true;
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertFalse("The beans should not have been setup since waitForSetup is true.", bean.initialized);
		}
		
		[Test]
		public function setUp_waitForSetupIsTrue_loadCompleteSwizEventIsNotDispatched():void
		{
			beanFactory.waitForSetup = true;
			mock(dispatcher).method("dispatchEvent").args(SwizEvent).never();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_waitForSetupIsFalse_beansAreSetup():void
		{
			beanFactory.waitForSetup = false;
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertTrue("The beans should have been setup since waitForSetup is false.", bean.initialized);
		}
		
		[Test]
		public function setUp_waitForSetupIsFalse_prototypeBeansAreNotSetup():void
		{
			beanFactory.waitForSetup = false
			var bean:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			assertFalse("The prototype beans should not have been setup.", bean.initialized);
		}
		
		[Test]
		public function setUp_catchViewsIsFalse_doesNotListenForSetUpEvent():void
		{
			stub(swiz).getter("catchViews").returns(false);
			mock(dispatcher).method("addEventListener").args(swiz.config.setUpEventType, Function, Boolean, Number, Boolean).never();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsFalse_doesNotListenForTearDownEvent():void
		{
			stub(swiz).getter("catchViews").returns(false);
			mock(dispatcher).method("addEventListener").args(swiz.config.tearDownEventType, Function, Boolean, Number, Boolean).never();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_waitForSetupIsFalse_loadCompleteSwizEventIsDispatched():void
		{
			beanFactory.waitForSetup = false;
			stub(swiz).getter("catchViews").returns(true);
			mock(dispatcher).method("dispatchEvent").args(SwizEvent).once();
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrue_listensForSetUpEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			mock(dispatcher).method("addEventListener").args(swiz.config.setUpEventType, Function, Boolean, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrue_listensForTearDownEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			mock(dispatcher).method("addEventListener").args(swiz.config.tearDownEventType, Function, Boolean, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueAndSetUpEventTypeIsCreationComplete_listensForCreationCompleteEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.setUpEventType = FlexEvent.CREATION_COMPLETE;
			mock(dispatcher).method("addEventListener").args(FlexEvent.CREATION_COMPLETE, Function, Boolean, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueSetUpEventPhaseIsBubbling_listensForBubblingEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.setUpEventPhase = EventPhase.BUBBLING_PHASE;
			mock(dispatcher).method("addEventListener").args(swiz.config.setUpEventType, Function, false, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueSetUpEventPriorityIsSpecified_listensForCorrectEventPriority():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.setUpEventPriority = 23
			mock(dispatcher).method("addEventListener").args(swiz.config.setUpEventType, Function, Boolean, 23, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueAndTearDownEventTypeIsRemove_listensForRemoveEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.tearDownEventType = FlexEvent.REMOVE;
			mock(dispatcher).method("addEventListener").args(FlexEvent.REMOVE, Function, Boolean, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueTearDownEventPhaseIsBubbling_listensForBubblingEvent():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.tearDownEventPhase = EventPhase.BUBBLING_PHASE;
			mock(dispatcher).method("addEventListener").args(swiz.config.tearDownEventType, Function, false, Number, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		[Test]
		public function setUp_catchViewsIsTrueTearDownEventPriorityIsSpecified_listensForCorrectEventPriority():void
		{
			stub(swiz).getter("catchViews").returns(true);
			swizConfig.tearDownEventPriority = 23
			mock(dispatcher).method("addEventListener").args(swiz.config.tearDownEventType, Function, Boolean, 23, Boolean).once();
			stub(dispatcher).getter("type").returns(Object);
			beanFactory.setUp(swiz);
			verify(dispatcher);
		}
		
		//---------------------------------------------------------------
		//
		// tearDown tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function tearDown_singleBeanProviderWithBeans_removesBeans():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			beanFactory.tearDown();
			assertThat(beanFactory.beans, emptyArray());
		}
		
		[Test]
		public function tearDown_unlistensForAddBeanEvent():void
		{
			mock(dispatcher).method("removeEventListener").args(BeanEvent.ADD_BEAN, Function).once();
			beanFactory.setUp(swiz);
			beanFactory.tearDown();
			verify(dispatcher);
		}
		
		[Test]
		public function tearDown_unlistensForSetupBeanEvent():void
		{
			mock(dispatcher).method("removeEventListener").args(BeanEvent.SET_UP_BEAN, Function).once();
			beanFactory.setUp(swiz);
			beanFactory.tearDown();
			verify(dispatcher);
		}
		
		[Test]
		public function tearDown_unlistensForRemoveBeanEvent():void
		{
			mock(dispatcher).method("removeEventListener").args(BeanEvent.REMOVE_BEAN, Function).once();
			beanFactory.setUp(swiz);
			beanFactory.tearDown();
			verify(dispatcher);
		}
		
		[Test]
		public function tearDown_unlistensForTeardownBeanEvent():void
		{
			mock(dispatcher).method("removeEventListener").args(BeanEvent.TEAR_DOWN_BEAN, Function).once();
			beanFactory.setUp(swiz);
			beanFactory.tearDown();
			verify(dispatcher);
		}
		
		//---------------------------------------------------------------
		//
		// setUpBean tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function setUpBean_beanIsInitialized_beanIsNotSetUp():void
		{
			var bean:Bean = new Bean();
			bean.initialized = true;
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").anyArgs().never();
			mock(beanProcessor).method("setUpBean").anyArgs().never();
			beanFactory.setUpBean(bean);
			verifyProcessors();
		}
		
		[Test]
		public function setUpBean_beanIsNotInitialized_beanIsInitialized():void
		{
			var bean:Bean = new Bean();
			bean.initialized = false;
			beanFactory.setUp(swiz);
			beanFactory.setUpBean(bean);
			assertTrue("The bean should have been initialized.", bean.initialized);
		}
		
		[Test]
		public function setUpBean_beanIsNotInitialized_beanIsSetUp():void
		{
			var bean:Bean = new Bean();
			bean.initialized = false;
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("setUpMetadataTags").args(Array, bean).once();
			mock(beanProcessor).method("setUpBean").args(bean).once();
			beanFactory.setUpBean(bean);
			verifyProcessors();
		}
		
		[Test]
		public function setUpBean_beanIsPrototype_prototypeIsSetUp():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("setUpMetadataTags").args(Array, bean).once();
			mock(beanProcessor).method("setUpBean").args(bean).once();
			beanFactory.setUpBean(bean);
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// addBean tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function addBean_autoSetUpIsFalse_beanIsAdded():void
		{
			var bean:Bean = new Bean();
			beanFactory.addBean(bean, false);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function addBean_autoSetUpIsFalse_beanIsNotSetUp():void
		{
			var bean:Bean = new Bean();
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").anyArgs().never();
			mock(beanProcessor).method("setUpBean").anyArgs().never();
			beanFactory.addBean(bean, false);
			verifyProcessors();
		}
		
		[Test]
		public function addBean_autoSetUpIsTrue_beanIsAdded():void
		{
			var bean:Bean = new Bean();
			beanFactory.setUp(swiz);
			beanFactory.addBean(bean, true);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function addBean_autoSetUpIsTrue_beanIsSetUp():void
		{
			var bean:Bean = new Bean();
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").args(Array, bean).once();
			mock(beanProcessor).method("setUpBean").args(bean).once();
			beanFactory.addBean(bean, true);
			verifyProcessors();
		}
		
		[Test]
		public function addBean_autoSetUpIsFalseAndBeanIsPrototype_beanIsAdded():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			beanFactory.addBean(bean, false);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function addBean_autoSetUpIsTrueAndBeanIsPrototype_beanIsAdded():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			beanFactory.setUp(swiz);
			beanFactory.addBean(bean, true);
			assertThat(beanFactory.beans, hasItem(bean));
		}
		
		[Test]
		public function addBean_autoSetUpIsTrueAndBeanIsPrototype_prototypeIsNotSetUp():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").anyArgs().never();
			mock(beanProcessor).method("setUpBean").anyArgs().never();
			beanFactory.addBean(bean, true);
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// addBeanProvider tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function addBeanProvider_autoSetUpBeansIsFalse_beansAreAdded():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(newBeanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.addBeanProvider(newBeanProvider, false);
			assertThat(beanFactory.beans, hasItems(bean, prototype));
		}
		
		[Test]
		public function addBeanProvider_autoSetUpBeansIsFalse_beansAreNotSetUp():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(newBeanProvider).getter("beans").returns([bean, prototype]);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").anyArgs().never();
			mock(beanProcessor).method("setUpBean").anyArgs().never();
			beanFactory.addBeanProvider(newBeanProvider, false);
			verifyProcessors();
		}
		
		[Test]
		public function addBeanProvider_autoSetUpBeansIsTrue_beansAreAdded():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(newBeanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.addBeanProvider(newBeanProvider, true);
			assertThat(beanFactory.beans, hasItems(bean, prototype));
		}
		
		[Test]
		public function addBeanProvider_autoSetUpBeansIsTrue_onlyBeansAreSetUp():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			beanFactory.setUp(swiz);
			stub(newBeanProvider).getter("beans").returns([bean, prototype]);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never();
			mock(metadataProcessor).method("setUpMetadataTags").args(Array, Bean).once();
			mock(beanProcessor).method("setUpBean").args(Bean).once();
			beanFactory.addBeanProvider(newBeanProvider, true);
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// tearDownBean tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function tearDownBean_beanIsInitialized_beanInitializedFlagIsReset():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			beanFactory.tearDownBean(bean);
			assertFalse("The bean should have had its initialized flag reset.", bean.initialized);
		}
		
		[Test]
		public function tearDownBean_beanIsTornDown():void
		{
			var bean:Bean = new Bean();
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").args(Array, Bean).once();
			mock(beanProcessor).method("tearDownBean").args(Bean).once();
			beanFactory.tearDownBean(bean);
			verifyProcessors();
		}
		
		[Test]
		public function tearDownBean_beanIsPrototype_prototypeIsTornDown():void
		{
			var bean:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean]);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").args(Array, Bean).once();
			mock(beanProcessor).method("tearDownBean").args(Bean).once();
			beanFactory.tearDownBean(bean);
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// removeBean tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function removeBean_beanIsRemoved():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(bean);
			assertThat(beanFactory.beans, arrayWithSize(1));
		}
		
		[Test]
		public function removeBean_beanIsTornDown():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").args(Array, Bean).once();
			mock(beanProcessor).method("tearDownBean").args(Bean).once();
			beanFactory.removeBean(bean);
			verifyProcessors();
		}
		
		[Test]
		public function removeBean_beansBeanFactoryIsNull():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(bean);
			assertNull("The bean's bean factory should be null", bean.beanFactory);
		}
		
		[Test]
		public function removeBean_beansSourceIsNull():void
		{
			var bean:Bean = new Bean(String);
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(bean);
			assertNull("The bean's source should be null", bean.source);
		}
		
		[Test]
		public function removeBean_beansTypeDescriptorIsNull():void
		{
			var bean:Bean = new Bean(String, "someString", new TypeDescriptor());
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(bean);
			assertNull("The bean's typeDescriptor should be null", bean.typeDescriptor);
		}
		
		[Test]
		public function removeBean_nonExistentBean_beanIsNotRemoved():void
		{
			var bean:Bean = new Bean(String);
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(new Bean(Number));
			assertThat(beanFactory.beans, arrayWithSize(2));
		}
		
		[Test]
		public function removeBean_nonExistentBean_beanIsNotTornDown():void
		{
			var bean:Bean = new Bean(String);
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").anyArgs().never();
			mock(beanProcessor).method("tearDownBean").anyArgs().never();
			beanFactory.removeBean(new Bean(Number));
			verifyProcessors();
		}
		
		[Test]
		public function removeBean_prototypeIsRemoved():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(prototype);
			assertThat(beanFactory.beans, arrayWithSize(1));
		}
		
		[Test]
		public function removeBean_nonExistentPrototype_prototypeIsNotRemoved():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBean(new Prototype());
			assertThat(beanFactory.beans, arrayWithSize(2));
		}
		
		[Test]
		public function removeBean_nonExistentPrototype_prototypeIsNotTornDown():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").anyArgs().never();
			mock(beanProcessor).method("tearDownBean").anyArgs().never();
			beanFactory.removeBean(new Prototype());
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// removeBeanProvider tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function removeBeanProvider_beansAreRemoved():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBeanProvider(beanProvider);
			assertThat(beanFactory.beans, emptyArray());
		}
		
		[Test]
		public function removeBeanProvider_beansBeanFactoryIsNull():void
		{
			var bean:Bean = new Bean();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBeanProvider(beanProvider);
			assertNull("The bean's bean factory should be null", bean.beanFactory);
		}
		
		[Test]
		public function removeBeanProvider_beansSourceIsNull():void
		{
			var bean:Bean = new Bean(String);
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBeanProvider(beanProvider);
			assertNull("The bean's source should be null", bean.source);
		}
		
		[Test]
		public function removeBeanProvider_beansTypeDescriptorIsNull():void
		{
			var bean:Bean = new Bean(String, "someString", new TypeDescriptor());
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			beanFactory.removeBeanProvider(beanProvider);
			assertNull("The bean's typeDescriptor should be null", bean.typeDescriptor);
		}
		
		[Test]
		public function removeBeanProvider_nonExistentBeans_beansAreNotRemoved():void
		{
			var bean:Bean = new Bean(String);
			var prototype:Prototype = new Prototype(SomePresentationModel);
			stub(beanProvider).getter("beans").returns([bean, prototype]);
			beanFactory.setUp(swiz);
			stub(newBeanProvider).getter("beans").returns([new Bean(IEventDispatcher), new Prototype(Number)]);
			beanFactory.removeBeanProvider(newBeanProvider);
			assertThat(beanFactory.beans, arrayWithSize(2));
		}
		
		[Test]
		public function removeBeanProvider_nonExistentBeans_beansAreNotTornDown():void
		{
			setupStandardBeanFactory();
			stub(newBeanProvider).getter("beans").returns([new Bean(IEventDispatcher), new Prototype(Number)]);
			mock(factoryProcessor).method("setUpFactory").anyArgs().never(); // Make sure the expectation is set AFTER the factory is setup
			mock(metadataProcessor).method("tearDownMetadataTags").anyArgs().never();
			mock(beanProcessor).method("tearDownBean").anyArgs().never();
			beanFactory.removeBeanProvider(newBeanProvider);
			verifyProcessors();
		}
		
		//---------------------------------------------------------------
		//
		// getBeanByName tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function getBeanByName_beanExists_beanIsFound():void
		{
			var beans:Array = setupStandardBeanFactory();
			var bean:Bean = Bean(beans[0]);
			assertStrictlyEquals("A named bean should have been found.", bean, beanFactory.getBeanByName("test"));
		}
		
		[Test]
		public function getBeanByName_beanDoesNotExist_beanIsNotFound():void
		{
			setupStandardBeanFactory();
			assertNull("A named bean should not have been found.", beanFactory.getBeanByName("invalidName"));
		}
		
		// TODO This test should be part of the setUp test and should verify that any two beans/prototypes cannot have the same name
		[Test]
		public function getBeanByName_twoBeansWithSameName_beanIsNotFound():void
		{
			var bean1:Bean = new Bean(String, "test");
			var bean2:Bean = new Bean(String, "test");
			setupStandardBeanFactoryWithBeans([bean1, bean2]);
			assertNull("A named bean should not have been found.", beanFactory.getBeanByName("test"));
		}
		
		[Test]
		public function getBeanByName_prototypeExists_prototypeIsFound():void
		{
			var bean:Bean = new Bean(String, "test");
			var prototype:Prototype = new Prototype(SomePresentationModel);
			prototype.name = "prototypeTest";
			setupStandardBeanFactoryWithBeans([bean, prototype]);
			assertStrictlyEquals("A named prototype should have been found.", prototype, beanFactory.getBeanByName("prototypeTest"));
		}
		
		[Test]
		public function getBeanByName_prototypeDoesNotExist_prototypeIsNotFound():void
		{
			var bean:Bean = new Bean(String, "test");
			var prototype:Prototype = new Prototype(SomePresentationModel);
			prototype.name = "prototypeTest";
			setupStandardBeanFactoryWithBeans([bean, prototype]);
			assertNull("A named prototype should not have been found.", beanFactory.getBeanByName("invalidName"));
		}
		
		[Test]
		public function getBeanByName_beanExistsInParent_beanIsFound():void
		{
			setupStandardBeanFactory();
			var bean:Bean = new Bean(Number, "number");
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [bean]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertStrictlyEquals("A named bean should have been found.", bean, beanFactory.getBeanByName("number"));
		}
		
		[Test]
		public function getBeanByName_beanDoesNotExistInParentOrChildBeanFactory_beanIsNotFound():void
		{
			setupStandardBeanFactory();
			var bean:Bean = new Bean(Number, "number");
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [bean]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertNull("A named bean should not have been found.", beanFactory.getBeanByName("invalidName"));
		}
		
		[Test]
		public function getBeanByName_prototypeExistsInParent_prototypeIsFound():void
		{
			setupStandardBeanFactory();
			var prototype:Prototype = new Prototype(SomeOtherPresentationModel);
			prototype.name = "prototypeTest";
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [prototype]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertStrictlyEquals("A named prototype should have been found.", prototype, beanFactory.getBeanByName("prototypeTest"));
		}
		
		[Test]
		public function getBeanByName_prototypeDoesNotExistInParentOrChildBeanFactory_prototypeIsNotFound():void
		{
			setupStandardBeanFactory();
			var prototype:Prototype = new Prototype(SomeOtherPresentationModel);
			prototype.name = "prototypeTest";
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [prototype]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertNull("A named prototype should not have been found.", beanFactory.getBeanByName("invalidName"));
		}
		
		//---------------------------------------------------------------
		//
		// getBeanByType tests
		//
		//---------------------------------------------------------------
		
		[Test]
		public function getBeanByType_beanExists_beanIsFound():void
		{
			var beans:Array = setupStandardBeanFactory();
			var bean:Bean = Bean(beans[0]);
			assertStrictlyEquals("A bean by type should have been found.", bean, beanFactory.getBeanByType(String));
		}
		
		[Test]
		public function getBeanByType_beanDoesNotExist_beanIsNotFound():void
		{
			var bean:Bean = new Bean(String, "test");
			var prototype:Prototype = new Prototype(SomePresentationModel);
			setupStandardBeanFactoryWithBeans([bean, prototype]);
			assertNull("A bean by type should not have been found.", beanFactory.getBeanByType(Number));
		}
		
		// TODO My suggestion is that a typed exception be thrown (org.swizframework.core.AmbiguousReferenceError) instead of a generic Error.
		[Test (expects="Error")]
		public function getBeanByType_twoBeansOfSameType_throwsAmbiguousReferenceError():void
		{
			var bean1:Bean = new Bean(String, "test1");
			var bean2:Bean = new Bean(String, "test2");
			setupStandardBeanFactoryWithBeans([bean1, bean2]);
			beanFactory.getBeanByType(String);
			fail("An AmbiguousReferenceError should have been thrown."); 
		}
		
		[Test]
		public function getBeanByType_prototypeExists_prototypeIsFound():void
		{
			var beans:Array = setupStandardBeanFactory();
			var prototype:Prototype = Prototype(beans[1]);
			assertStrictlyEquals("A prototype by type should have been found.", prototype, beanFactory.getBeanByType(SomePresentationModel));
		}
		
		// TODO My suggestion is that a typed exception be thrown (org.swizframework.core.AmbiguousReferenceError) instead of a generic Error.
		[Test (expects="Error")]
		public function getBeanByType_twoPrototypesOfSameType_throwsAmbiguousReferenceError():void
		{
			var prototype1:Prototype = new Prototype(String);
			var prototype2:Prototype = new Prototype(String);
			setupStandardBeanFactoryWithBeans([prototype1, prototype2]);
			beanFactory.getBeanByType(String);
			fail("An AmbiguousReferenceError should have been thrown."); 
		}
		
		[Test]
		public function getBeanByType_beanExistsInParent_beanIsFound():void
		{
			setupStandardBeanFactory();
			var bean:Bean = new Bean(Number, "number");
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [bean]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertStrictlyEquals("A bean by type should have been found.", bean, beanFactory.getBeanByType(Number));
		}
		
		// TODO My suggestion is that a typed exception be thrown (org.swizframework.core.AmbiguousReferenceError) instead of a generic Error.
		[Test (expects="Error")]
		public function getBeanByType_twoBeansOfSameTypeOneInChildOneInParent_throwsAmbiguousReferenceError():void
		{
			setupStandardBeanFactory();
			var bean:Bean = new Bean(String, "test2");
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [bean]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			beanFactory.getBeanByType(String);
			fail("An AmbiguousReferenceError should have been thrown."); 
		}
		
		[Test]
		public function getBeanByType_beanDoesNotExistInParentOrChildBeanFactory_beanIsNotFound():void
		{
			setupStandardBeanFactory();
			var bean:Bean = new Bean(Number, "number");
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [bean]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertNull("A bean by type should not have been found.", beanFactory.getBeanByType(Array));
		}
		
		[Test]
		public function getBeanByType_prototypeExistsInParent_prototypeIsFound():void
		{
			setupStandardBeanFactory();
			var prototype:Prototype = new Prototype(SomeOtherPresentationModel);
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [prototype]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			assertStrictlyEquals("A prototype by type should have been found.", prototype, beanFactory.getBeanByType(SomeOtherPresentationModel));
		}
		
		// TODO My suggestion is that a typed exception be thrown (org.swizframework.core.AmbiguousReferenceError) instead of a generic Error.
		[Test (expects="Error")]
		public function getBeanByType_twoPrototypesOfSameTypeOneInChildOneInParent_throwsAmbiguousReferenceError():void
		{
			setupStandardBeanFactory();
			var prototype:Prototype = new Prototype(SomePresentationModel);
			setupBeanFactoryWithBeans(parentBeanFactory, parentSwiz, parentBeanProvider, [prototype]);
			beanFactory.parentBeanFactory = parentBeanFactory;
			beanFactory.getBeanByType(SomePresentationModel);
			fail("An AmbiguousReferenceError should have been thrown."); 
		}
		
		//---------------------------------------------------------------
		//
		// Miscellaneous internal functions
		//
		//---------------------------------------------------------------
		
		private function verifyProcessors():void
		{
			verify(factoryProcessor);
			verify(metadataProcessor);
			verify(beanProcessor);
		}
		
		//---------------------------------------------------------------
		//
		// Helpers
		//
		//---------------------------------------------------------------
		private function setupStandardBeanFactory():Array
		{
			var bean:Bean = new Bean(String, "test");
			var prototype:Prototype = new Prototype(SomePresentationModel);
			return setupStandardBeanFactoryWithBeans([bean, prototype]);
		}
		
		private function setupStandardBeanFactoryWithBeans(beans:Array):Array
		{
			return setupBeanFactoryWithBeans(beanFactory, swiz, beanProvider, beans);
		}
		
		private function setupBeanFactoryWithBeans(factory:IBeanFactory, theSwiz:ISwiz, provider:IBeanProvider, beans:Array):Array
		{
			for each ( var bean:Bean in beans )
			{
				bean.typeDescriptor = new TypeDescriptor();
				if ( bean is Prototype )
				{
					bean.typeDescriptor.className = getQualifiedClassName(Prototype(bean).type);
				}
				else
				{
					bean.typeDescriptor.className = getQualifiedClassName(bean.source);
				}
			}
			stub(provider).getter("beans").returns(beans);
			factory.setUp(theSwiz);
			return beans;
		}
	}
}