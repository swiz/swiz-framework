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
			trace( "BeanManager::processBeanProviders()" );
			typeDescriptors ||= new Dictionary();
			beans ||= new Dictionary();
			
			for each( var providerClass:Class in providerClasses )
			{
				trace( "BeanManager creating instance of provider class", getQualifiedClassName( providerClass ) );
				// TODO: add support for passing in instances
				var providerInstance:* = new providerClass();
				// get public props.
				// TODO add accessor support?
				trace( "BeanManager calling describeType() for bean provider instance" );
				var providerPublicProps:XMLList = describeType( providerInstance ).variable;
				
				trace( "BeanManager iterating over public properties (beans) of bean provider instance" );
				for each( var beanNode:XML in providerPublicProps )
				{
					var beanName:String = beanNode.@name.toString();
					
					var beanClassName:String = beanNode.@type;
					trace( "BeanManager checking to see if we already have type info for", beanClassName );
					if( typeDescriptors[ beanClassName ] == null )
					{
						trace( "BeanManager does not have type info for", beanClassName );
						var td:TypeDescriptor = new TypeDescriptor().fromXML( describeType( providerInstance[ beanName ] ) );
						trace( "BeanManager storing", beanClassName, "type info" );
						typeDescriptors[ beanClassName ] = td;
					}
					else
					{
						trace( "BeanManager already has type info for", beanClassName, ", moving on" );
					}
					
					// create Bean instance and store it
					var bean:Bean = new Bean();
					bean.name = beanName;
					bean.typeDescriptor = td;
					bean.instance = providerInstance[ beanName ];
					bean.autowiredStatus = AutowiredStatus.EMPTY;
					beans[ UIDUtil.getUID( bean.instance ) ] = bean.instance;
					trace( "BeanManager created Bean instance for", beanClassName );
				}
			}
		}
	}
}