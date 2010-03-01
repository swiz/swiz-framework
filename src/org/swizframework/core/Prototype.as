package org.swizframework.core
{
	import org.swizframework.events.BeanEvent;
	
	public class Prototype extends Bean
	{
		public var constructorArguments:*;
		public var singleton:Boolean = false;
		
		/**
		 *
		 */
		protected var _type:Class;
		
		override public function get type():*
		{
			return _type;
		}
		
		public function set type( clazz:Class ):void
		{
			_type = clazz;
		}
		
		override public function get source():*
		{
			return getObject();
		}
		
		public function Prototype( type:Class = null )
		{
			super();
			
			this.type = type;
		}
		
		protected function getObject():*
		{
			var instance:* = _source;
			
			if( _source == null )
			{
				// if source is null, create and initialize it (runs all processors)
				_source = instance = createInstance();
				beanFactory.initializeBean( new Bean( _source, name, typeDescriptor ) );
				
				// if this prototype is not a singleton, remove the source
				if( !singleton )
					_source = null;
			}
			
			return instance;
		}
		
		protected function createInstance():Object
		{
			if( type == null )
				throw new Error( "Bean Creation exception! You must supply type to Prototype!" );
			
			var instance:*;
			
			if( constructorArguments != null )
			{
				var args:Array = constructorArguments is Array ? constructorArguments : [constructorArguments ];
				
				switch( args.length )
				{
					case 1:
						instance = new type( args[ 0 ] );
						break;
					case 2:
						instance = new type( args[ 0 ], args[ 1 ] );
						break;
					case 3:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ] );
						break;
					case 4:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ] );
						break;
					case 5:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] );
						break;
					case 6:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ] );
						break;
					case 7:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ] );
						break;
					case 8:
						instance = new type( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 7 ], args[ 8 ] );
						break;
				}
			}
			else
			{
				instance = new type();
			}
			
			return instance;
		}
	}
}