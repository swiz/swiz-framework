package org.swizframework.ioc
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;
	
	import org.swizframework.di.AutowiredStatus;
	import org.swizframework.di.Bean;
	import org.swizframework.reflection.TypeDescriptor;
	
	public class BeanManager
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Catalog of TypeDescriptor instances keyed by fully
		 * qualified class name of type being represented.
		 * 
		 * @see org.swizframework.di.TypeDescriptor
		 */
		protected var typeDescriptors:Dictionary;
		
		/**
		 * Catalog of Bean instances keyed by UID of actual
		 * managed object wrapped by Bean instance.
		 * 
		 * @see org.swizframework.di.Bean
		 */
		protected var beans:Dictionary;
		
		// ========================================
		// constructor
		// ========================================
		
		public function BeanManager()
		{
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Get TypeDescriptor instance for provided bean. If a TypeDescriptor
		 * has already been created for this type that instance will be returned.
		 * 
		 * @see org.swizframework.di.TypeDescriptor
		 */
		protected function getTypeDescriptor( beanInstance:* ):TypeDescriptor
		{
			// name of the property's class
			var beanClassName:String = getQualifiedClassName( beanInstance );
			
			var td:TypeDescriptor = typeDescriptors[ beanClassName ];
			
			// check to see if we already have a TypeDescriptor for this class type
			if( td == null )
			{
				// existing TypeDescriptor not found, so create one and store it
				// TODO: implement type caching
				td = new TypeDescriptor().fromXML( describeType( beanInstance ) );
				typeDescriptors[ beanClassName ] = td;
			}
			
			return td;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Processes an <code>Array</code> of classes that contain
		 * objects to be managed by Swiz (aka beans). The provider classes
		 * will be instantiated within this method and all resulting publicly
		 * readable properties will become beans.
		 */
		public function processBeanProviders( providerClasses:Array ):void
		{
			// make sure dictionaries are instantiated
			typeDescriptors ||= new Dictionary();
			beans ||= new Dictionary();
			
			// iterate over passed in classes
			for each( var providerClass:Class in providerClasses )
			{
				// TODO: add support for passing in instances?
				// create instance of passed in class
				var providerInstance:* = new providerClass();
				// get all readable public properties of provider class instance
				// TODO: implement type caching
				var providerDescription:XML = describeType( providerInstance );
				var beanList:XML = <beans />;
				beanList.appendChild( providerDescription.variable );
				beanList.appendChild( providerDescription.accessor.( @access != "writeOnly" ) );
				
				// iterate over public properties (beans) of bean provider instance
				for each( var beanNode:XML in beanList.children() )
				{
					// name of the property
					var beanName:String = beanNode.@name.toString();
					// ref to actual bean
					var beanInstance:* = providerInstance[ beanName ];
					
					var td:TypeDescriptor = getTypeDescriptor( beanInstance );
					
					// create Bean instance and store it
					var bean:Bean = new Bean();
					bean.name = beanName;
					bean.typeDescriptor = td;
					bean.instance = beanInstance;
					bean.autowiredStatus = AutowiredStatus.EMPTY;
					beans[ UIDUtil.getUID( beanInstance ) ] = beanInstance;
				}
			}
		}
	}
}