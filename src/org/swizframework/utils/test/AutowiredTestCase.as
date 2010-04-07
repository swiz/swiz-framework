package org.swizframework.utils.test
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.Swiz;
	import org.swizframework.reflection.TypeCache;
	
	/**
	 * AutowiredTestCase provides a base class for unit testing that provides autowiring.
	 * A child test case should set the beanProvider property in it's constructor. A new 
	 * Swiz Context will be created in the test's [Before] method.
	 */
	public class AutowiredTestCase extends EventDispatcher
	{
		/**
		 * Backing variable for <code>beanProvider</code> getter/setter.
		 */
		private var _beanProviders:Array;
		
		/**
		 * Backing variable for <code>swiz</code> getter/setter.
		 */
		private var _swiz:Swiz;
		
		public function AutowiredTestCase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * Setter for beanProvider property.
		 */
		public function set beanProviders(beanProviders:Array):void
		{
			_beanProviders = beanProviders;
		}
		
		
		/**
		 * Getter for beanProvider property.
		 */
		public function get beanProviders():Array
		{
			return _beanProviders;
		}
		
		/**
		 * Getter for local Swiz instance.
		 */
		public function get swiz():Swiz
		{
			return _swiz;
		}
		
		/**
		 * 
		 */ 
		[Before]
		public function constructSwizContext():void
		{
			
			trace("constructSwizContext() called");
			
			// initialize bean factory with configurec bean provider
			if( _swiz == null && _beanProviders != null )
			{
				_swiz = new Swiz(null, null, null, _beanProviders);
				_swiz.init();
				
				// wrap the unit test in a Bean definition
				var bean:Bean = new Bean();
				bean.source = this;
				bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, _swiz.domain );
				
				// autowire test case with bean factory
				_swiz.beanFactory.setUpBean( bean );
			}
		}
	
	}
}