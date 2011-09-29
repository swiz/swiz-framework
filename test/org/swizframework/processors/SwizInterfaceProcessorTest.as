package org.swizframework.processors
{
	import flash.events.IEventDispatcher;
	
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.strictlyEqualTo;
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanFactory;
	import org.swizframework.core.IBeanFactoryAware;
	import org.swizframework.core.IDispatcherAware;
	import org.swizframework.core.IDisposable;
	import org.swizframework.core.IInitializing;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;

	public class SwizInterfaceProcessorTest
	{	
		[Rule]
		public var rule:MockolateRule = new MockolateRule();
		
		[Mock]
		public var swiz:ISwiz;
		
		[Mock]
		public var beanFactory:IBeanFactory;
		
		[Mock]
		public var dispatcher:IEventDispatcher;
		
		[Mock]
		public var swizAware:ISwizAware;
		
		[Mock]
		public var beanFactoryAware:IBeanFactoryAware;
		
		[Mock]
		public var dispatcherAware:IDispatcherAware;
		
		[Mock]
		public var initializing:IInitializing;
		
		[Mock]
		public var disposable:IDisposable;
		
		[Mock]
		public var bean:Bean;
		
		private var processor:SwizInterfaceProcessor;
		
		[Before]
		public function setUp():void
		{
			processor = new SwizInterfaceProcessor();
			processor.init(swiz);
			
			stub(swiz).getter("beanFactory").returns(beanFactory);
			stub(swiz).getter("dispatcher").returns(dispatcher);
		}
		
		//------------------------------------------------------
		//
		// setUpBean tests
		//
		//------------------------------------------------------
		
		[Test]
		public function setUpBean_beanTypeIsISwizAware_setsSwizOnBeanType():void
		{
			stub(bean).getter("type").returns(swizAware);
			mock(swizAware).setter("swiz").arg(strictlyEqualTo(swiz)).once();
			processor.setUpBean(bean);
		}
	
		[Test]
		public function setUpBean_beanTypeIsIBeanFactoryAware_setsBeanFactoryOnBeanType():void
		{
			stub(bean).getter("type").returns(beanFactoryAware);
			mock(beanFactoryAware).setter("beanFactory").arg(strictlyEqualTo(beanFactory)).once();
			processor.setUpBean(bean);
		}
		
		[Test]
		public function setUpBean_beanTypeIsIDispatcherAware_setsDispatcherOnBeanType():void
		{
			stub(bean).getter("type").returns(dispatcherAware);
			mock(dispatcherAware).setter("dispatcher").arg(strictlyEqualTo(dispatcher)).once();
			processor.setUpBean(bean);
		}
		
		[Test]
		public function setUpBean_beanTypeIsIInitializing_invokesAfterPropertiesSetOnBeanType():void
		{
			stub(bean).getter("type").returns(initializing);
			mock(initializing).method("afterPropertiesSet").once();
			processor.setUpBean(bean);
		}
		
		//------------------------------------------------------
		//
		// tearDownBean tests
		//
		//------------------------------------------------------
		
		[Test]
		public function tearDownBean_beanTypeIsISwizAware_nullsSwizOnBeanType():void
		{
			stub(bean).getter("type").returns(swizAware);
			mock(swizAware).setter("swiz").arg(nullValue()).once();
			processor.tearDownBean(bean);
		}
		
		[Test]
		public function tearDownBean_beanTypeIsIBeanFactoryAware_nullsBeanFactoryOnBeanType():void
		{
			stub(bean).getter("type").returns(beanFactoryAware);
			mock(beanFactoryAware).setter("beanFactory").arg(nullValue()).once();
			processor.tearDownBean(bean);
		}
		
		[Test]
		public function tearDownBean_beanTypeIsIDispatcherAware_nullsDispatcherOnBeanType():void
		{
			stub(bean).getter("type").returns(dispatcherAware);
			mock(dispatcherAware).setter("dispatcher").arg(nullValue()).once();
			processor.tearDownBean(bean);
		}
		
		[Test]
		public function tearDownBean_beanTypeIsIDisposable_invokesDisposeOnBeanType():void
		{
			stub(bean).getter("type").returns(disposable);
			mock(disposable).method("destroy").once();
			processor.tearDownBean(bean);
		}
	}
}