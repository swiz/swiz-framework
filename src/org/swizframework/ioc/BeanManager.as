package org.swizframework.ioc
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
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
		
		// ========================================
		// constructor
		// ========================================
		
		public function BeanManager()
		{
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function processBeanProvider( provider:Class ):void
		{
			trace( "BeanManager::processBeanProvider()" );
			typeDescriptors ||= new Dictionary();
			
			trace( "BeanManager creating instance of provider class" );
			// TODO: add support for passing in instances
			var providerInstance:* = new provider();
			// get public props.
			// TODO add accessor support
			trace( "BeanManager calling describeType() for bean provider instance" );
			var providerPublicProps:XMLList = describeType( providerInstance ).variable;
			
			trace( "BeanManager iterating over public properties (beans) of bean provider instance" );
			for each( var beanNode:XML in providerPublicProps )
			{
				var beanClassName:String = beanNode.@type;
				trace( "BeanManager checking to see if we already have type info for", beanClassName );
				if( typeDescriptors[ beanClassName ] == null )
				{
					trace( "BeanManager does not have type info for", beanClassName );
					var td:TypeDescriptor = new TypeDescriptor().fromXML( describeType( providerInstance[ beanNode.@name.toString() ] ) );
					trace( "BeanManager storing", beanClassName, "type info" );
					typeDescriptors[ beanClassName ] = td;
				}
				else
				{
					trace( "BeanManager already has type info for", beanClassName, ", moving on" );
				}
			}
		}
	}
}