package org.swizframework.processors
{
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.Prototype;
	import org.swizframework.mediation.IMediator;
	import org.swizframework.mediation.IMediatorMapping;
	import org.swizframework.mediation.MediatorMap;
	import org.swizframework.reflection.TypeCache;
	
	public class MediatorMapProcessor implements IBeanProcessor
	{
		private var _swiz:ISwiz;
		
		public function setUpBean( bean:Bean ):void
		{
			if( bean is Prototype || !_swiz.mediatorMaps )
				return;
			
			for each( var map:MediatorMap in _swiz.mediatorMaps )
			{
				for each( var mapping:IMediatorMapping in map.mappings )
				{
					if( !mapping.matches( bean.source ) )
						continue;
					
					if( _swiz.beanFactory.getBeanByType( mapping.mediatorType ) == null )
					{
						// create a Prototype for adding to the BeanFactory
						var mediatorPrototype:Prototype = new Prototype( mapping.mediatorType );
						mediatorPrototype.typeDescriptor = TypeCache.getTypeDescriptor( mapping.mediatorType, _swiz.domain );
						// add command bean for later instantiation
						_swiz.beanFactory.addBean( mediatorPrototype, false );
					}
					
					var proto:Prototype = _swiz.beanFactory.getBeanByType( mapping.mediatorType ) as Prototype;
					
					var mediator:* = proto.source;
					
					if( !( mediator is IMediator ) )
						throw new Error( "MUST implement IMediator" );
					
					IMediator( mediator ).mediate( bean.source );
				}
			}
		}
		
		public function tearDownBean(bean:Bean):void
		{
		}
		
		public function init( swiz:ISwiz ):void
		{
			_swiz = swiz;
		}
		
		public function get priority():int
		{
			return 0;
		}
	}
}