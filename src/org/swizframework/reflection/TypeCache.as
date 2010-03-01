package org.swizframework.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Static class used to ensure each type is only inspected via <code>describeType</code>
	 * a single time.
	 */
	public class TypeCache
	{
		/**
		 * Dictionary of previously inspected types.
		 */
		protected static var typeDescriptors:Dictionary;
		
		/**
		 * Will return TypeDescriptor instance either retrieved from cache or freshly
		 * constructed from <code>describeType</code> call.
		 *
		 * @param target Object whose type is to be inspected and returned.
		 * @return TypeDescriptor instance representing the type of the object that was passed in.
		 */
		public static function getTypeDescriptor( target:Object ):TypeDescriptor
		{
			// make sure our Dictionary has been initialized
			typeDescriptors ||= new Dictionary();
			
			// check for this type in Dictionary and return it if it already exists
			var className:String = getQualifiedClassName( target );
			if( typeDescriptors[ className ] != null )
				return typeDescriptors[ className ];
			
			// type not found in cache so create, store and return it here
			return typeDescriptors[ className ] = new TypeDescriptor().fromXML( describeType( target ) );
		}
	}
}