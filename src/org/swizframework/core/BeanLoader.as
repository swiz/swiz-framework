package org.swizframework.core
{
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	
	import org.swizframework.reflection.TypeCache;
	
	[DefaultProperty( "beans" )]

	public class BeanLoader extends EventDispatcher implements IBeanProvider
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>dispatcher</code> getter/setter.
		 */
		protected var _dispatcher:IEventDispatcher;
		
		/**
		 * Backing variable for <code>beans</code> getter.
		 */
		protected var _beans:Array = [];
		
		
		// ========================================
		// public properties
		// ========================================
		
		[Bindable]
		/**
		 * Dispatcher used for sending app level notifications by classes that will not live on display list.
		 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher( value:IEventDispatcher ):void
		{
			_dispatcher = value;
		}
		
		[ArrayElementType( "Object" )]
		/**
		 * Beans
		 * ([ArrayElementType( "Object" )] metadata is to avoid http://j.mp/FB-12316)
		 */
		public function get beans():Array
		{
			return _beans;
		}
		
		public function set beans( value:Array ):void
		{
			if( value != _beans )
			{
				// got rid of remove beans, it didn't do anything...
				initializeBeans( value );
			}
		}
		
		
		// ========================================
		// Constructor
		// ========================================
		
		/**
		 * Constructor
		 */ 
		public function BeanLoader( beans:Array = null )
		{
			super();
			this.beans = beans;
		}
		
		
		// ========================================
		// public methods
		// ========================================

		public function initialize():void
		{
			setBeanIds();
		}
		
		public function addBean( bean:Bean ):void
		{
			if( beans )
			{
				beans[ beans.length ] = bean;
			}
			else
			{
				beans = [ bean ];
			}
			
			// now initialize the bean...
		}
		
		public function removeBean( bean:Bean ):void
		{
			if( beans )
			{
				beans.splice( beans.indexOf( bean ), 1 );
			}
			
			// clean the bean?
		}
		
		
		// ========================================
		// protected methods
		// ========================================
		
		protected function initializeBeans( beansArray:Array ):void
		{
			for each( var beanSource:Object in beansArray )
			{
				_beans.push( constructBean( beanSource ) );
			}
		}
		
		/**
		 * Since the setter for beans should have already created Bean objects for all children, 
		 * we are primarily trying to identify the id to set in the bean's name property.
		 * 
		 * However, something is really wierd with using ids or not, and wether we will
		 * actually have an array of beans at this time, so if we don't find a Bean for an 
		 * element we find in describeType, we created it.
		 */ 
		protected function setBeanIds():void
		{
			var xmlDescription:XML = describeType( this );
			var accessors:XMLList = xmlDescription.accessor.( @access == "readwrite" ).@name;
			
			var child:*;
			var name:String;
			var found:Boolean;
			
			for( var i:uint = 0; i<accessors.length(); i++ )
			{
				name = accessors[ i ];
				if( name != "beans" )
				{
					
					// BeanProvider will take care of setting the type descriptor, 
					// but we want to wrap the intances in Bean classes to set the Bean.name to id
					child = this[ name ];
					
					if ( child != null )
					{
						found = false;
						
						// look for any bean we should already have, and set the name propery of the bean object only
						for each( var bean:Bean in beans )
						{
							if( ( bean == child ) || ( bean.source == child ) )
							{
								bean.name = name;
								found = true;
								break;
							}
						}
						
						// if we didn't find the bean, we need to construct it
						if( !found )
						{
							beans.push( constructBean( child, name ) );
						}
					}
					
				}
			}
		}
		
		// both init method and setBeanIds will call this if needed
		private function constructBean( obj:*, name:String=null ):Bean 
		{
			var bean:Bean = null;
			
			if( obj is Bean )
			{
				bean = Bean( obj );
			}
			else
			{
				bean = new Bean();
				bean.source = obj;
			}
			
			bean.name = name;
			bean.provider = this;
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type );
			
			return bean;
		}

	}
}
