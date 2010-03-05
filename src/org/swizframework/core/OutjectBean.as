package org.swizframework.core
{
	import org.swizframework.reflection.TypeDescriptor;
	
	public class OutjectBean extends Bean
	{
		public function OutjectBean( source:* = null, name:String = null, typeDescriptor:TypeDescriptor = null, provider:IBeanProvider = null )
		{
			super( source, name, typeDescriptor, provider );
		}
		
		/**
		 * Beans that are created in response to [Outject] need
		 * a reference to the bean in which they are defined
		 * so the resulting binding can be created as a 
		 * binding to that parent's property.
		 */
		public var parentBean:Bean;
		
		/**
		 * Name of property on parentBean that became this bean
		 * if this bean was an [Outject].
		 */
		public var outjectedPropName:String;
	}
}