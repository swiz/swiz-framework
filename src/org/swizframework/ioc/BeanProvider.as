package org.swizframework.ioc
{
	import flash.events.EventDispatcher;
	
	import org.swizframework.events.BeanEvent;
	
	[DefaultProperty( "beans" )]
	[Event( name="beanAdded", type="org.swizframework.events.BeanEvent" )]
	[Event( name="beanRemoved", type="org.swizframework.events.BeanEvent" )]
	
	/**
	 * Bean Loader
	 */
	public class BeanProvider extends EventDispatcher implements IBeanProvider
	{
		
		// ========================================
		// private properties
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter.
		 */
		private var _beans:Array;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Beans
		 */
		public function get beans():Array
		{
			return _beans;
		}
		
		public function set beans( value:Array ):void
		{
			if ( _beans != value )
			{
				removeBeans();
				_beans = value;
				addBeans();
			}
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanProvider( beans:Array = null )
		{
			super();
			
			this.beans = beans;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function addBean( bean:Object ):void
		{
			if ( beans )
			{
				beans[ beans.length ] = bean;
			}
			else
			{
				beans = [ bean ];
			}
			
			dispatchEvent( new BeanEvent( BeanEvent.ADDED, bean ) );
		}
		
		public function removeBean( bean:Object ):void
		{
			if ( beans )
			{
				beans.splice( beans.indexOf( bean ), 1 );
				dispatchEvent( new BeanEvent( BeanEvent.REMOVED, bean ) );
			}
		}
		
		public function getBeanByName( beanName:String ):Object
		{
			return null; //return beanId in beans ? beans[ beanId ] : null;
		}
		
		public function getBeanByType( beanType:Class ):Object
		{
			var foundBean:Object;
			
			for each( var bean:Object in beans )
			{
				if ( bean is beanType )
				{
					if ( foundBean != null )
					{
						throw new Error( "AmbiguousReferenceError. More than one bean was found with type: " + beanType );
					}
					
					foundBean = bean;
				}
			}
			
			return foundBean;
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		protected function addBeans():void
		{
			for each ( var bean:Object in beans )
			{
				dispatchEvent( new BeanEvent( BeanEvent.ADDED, bean ) );
			}
		}
		
		protected function removeBeans():void
		{
			for each ( var bean:Object in beans )
			{
				dispatchEvent( new BeanEvent( BeanEvent.REMOVED, bean ) );
			}
		}
		
	}
}