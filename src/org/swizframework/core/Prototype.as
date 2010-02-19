package org.swizframework.core
{
	import org.swizframework.events.BeanEvent;

	public class Prototype extends Bean
	{
		// public var className:String;
		public var classReference:Object;
		public var constructorArguments:*;
		public var singleton:Boolean = false;

		override public function get source():*
		{
			return getObject();
		}

		public function Prototype()
		{
			super();
		}
		
		protected function getObject():*
		{
			var instance:* = source;
			
			if (source == null) 
			{
				// if source is null, create and initialize it (runs all processors)
				source = instance = createInstance();
				beanFactory.initializeBean( new Bean( source, name, typeDescriptor ) );
				
				// if this prototype is not a singleton, remove the source
				if (!singleton) source = null;
			}
			
			return instance;
		}

		protected function createInstance():Object
		{
			if( classReference == null ) // && className == null)
				return null; // throw new Error( "Bean Creation exception! You must supply classReference or className to Prototype!" );
			
			// var clazz : Class = getClass();
			var instance:*;

			if( constructorArguments != null )
			{
				var args:Array = constructorArguments is Array ? constructorArguments : [constructorArguments ];

				switch( args.length )
				{
					case 1:
						instance = new classReference( args[ 0 ] );
						break;
					case 2:
						instance = new classReference( args[ 0 ], args[ 1 ] );
						break;
					case 3:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ] );
						break;
					case 4:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ] );
						break;
					case 5:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] );
						break;
					case 6:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ] );
						break;
					case 7:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ] );
						break;
					case 8:
						instance = new classReference( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 7 ], args[ 8 ] );
						break;
				}
			}
			else
			{
				instance = new classReference();
			}
			
			return instance;
		}
	}
}