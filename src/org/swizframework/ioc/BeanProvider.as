package org.swizframework.ioc
{
	import flash.events.EventDispatcher;
	
	import org.swizframework.di.Bean;
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
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter.
		 */
		protected var _beans:Array;
		
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
			if ( value != _beans )
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
			for each( var bean:Object in beans )
			{
				if( bean is Bean && Bean( bean ).name == beanName )
					return bean;
			}
			
			return null;
		}
		
		public function getBeanByType( beanType:Class ):Object
		{
			var foundBean:Object;
			
			for each( var bean:Object in beans )
			{
				if( bean is Bean && Bean( bean ).source is beanType )
				{
					foundBean = bean;
				}
				else if ( bean is beanType )
				{
					if ( foundBean != null )
					{
						throw new Error( "AmbiguousReferenceError. More than one bean was found with type: " + beanType );
					}
					
					foundBean = bean;
					var wtfBean:Bean = new Bean();
					wtfBean.source = foundBean;
					return wtfBean;
				}
			}
			
			return foundBean;
		}
	}
}