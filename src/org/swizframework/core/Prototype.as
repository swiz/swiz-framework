package org.swizframework.core
{
	import org.swizframework.events.BeanEvent;

	public class Prototype extends Bean
	{

		public var classReference:Object;
		public var constructorArguments:*;
		public var singleton:Boolean = false;

		override public function get source():*
		{
			if( singleton )
			{
				return super.source ||= createInstance();
			}
			else
			{
				var instance:Object = createInstance();

				return instance;
			}
		}

		public function Prototype()
		{
			super();
		}

		protected function createInstance():Object
		{
			if( classReference == null )
				return null;

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
			
			// todo: how does prototype get initialized now???
			// provider.dispatchEvent( new BeanEvent( BeanEvent.ADDED, new Bean( instance, name, typeDescriptor ) ) );

			return instance;
		}
	}
}