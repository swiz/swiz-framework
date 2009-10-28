package org.swizframework.ioc
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;
	
	import org.swizframework.di.AutowiredStatus;
	import org.swizframework.di.Bean;
	import org.swizframework.di.TypeDescriptor;
	
	public class BeanManager
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * 
		 */
		protected var typeDescriptors:Dictionary;
		
		/**
		 * 
		 */
		protected var beans:Dictionary;
		
		// ========================================
		// constructor
		// ========================================
		
		public function BeanManager()
		{
		}
		
		// ========================================
		// public methods
		// ========================================
		
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
					// name of the property's class
					var beanClassName:String = beanNode.@type;
					// ref to actual bean
					var beanInstance:* = providerInstance[ beanName ];
					
					// check to see if we already have a TypeDescriptor for this class type
					if( typeDescriptors[ beanClassName ] == null )
					{
						// existing TypeDescriptor not found, so create one and store it
						// TODO: implement type caching
						var td:TypeDescriptor = new TypeDescriptor().fromXML( describeType( beanInstance ) );
						typeDescriptors[ beanClassName ] = td;
					}
					
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