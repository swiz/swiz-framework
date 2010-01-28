package org.swizframework.utils.test
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.Swiz;
	import org.swizframework.events.BeanEvent;
	import org.swizframework.reflection.TypeCache;

	public class AutowiredTestCase extends EventDispatcher
	{
		private var _beanProviders:Array;
		private var _swiz:Swiz;
		
		public function AutowiredTestCase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function set beanProviders(beanProviders:Array):void
		{
			_beanProviders = beanProviders;
		}
		
		public function get beanProviders():Array
		{
			return _beanProviders;
		}
		
		[Before]
		public function constructSwizContext() : void {
			
			trace("constructSwizContext() called");
			
			// initialize bean factory with configurec bean provider
			if (_swiz == null && _beanProviders != null) {
				_swiz = new Swiz(null, null, null, _beanProviders);
				_swiz.init();
				
				// wrap the unit test in a Bean definition
				// wrap view component in Bean
				var bean:Bean = new Bean();
				bean.source = this;
				bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.source );
				
				// dispatch a bean added event, to autowire
				_beanProviders[0].dispatchEvent( new BeanEvent( BeanEvent.ADDED, bean ) );
			}
		}
		
	}
}