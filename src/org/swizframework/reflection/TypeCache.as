package org.swizframework.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	public class TypeCache
	{
		protected static var typeDescriptors:Dictionary;
		
		public static function getTypeDescriptor( target:Object ):TypeDescriptor
		{
			typeDescriptors ||= new Dictionary();
			
			var className:String = getQualifiedClassName( target );
			if( typeDescriptors[ className ] != null )
				return typeDescriptors[ className ];
			
			return typeDescriptors[ className ] = new TypeDescriptor().fromXML( describeType( target ) );
		}
	}
}