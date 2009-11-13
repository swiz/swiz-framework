package org.swizframework.util
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	public class MetadataUtil
	{
		
		private static var typeDescriptions:Object = {};
		private static var metadata:Object = {};
		
		public static function getTypeDescription( type:Class ):XML
		{
			if ( typeDescriptions[ type ] == null )
			{
				typeDescriptions[ type ] = describeType( type );
			}
			
			return typeDescriptions[ type ] as XML;
		}
		
		public static function getElementName( metadata:XML ):String
		{
			return metadata.parent().@name;
		}
		
		public static function getElementType( metadata:XML ):Class
		{
			var type:String = metadata.parent().@type;

			return type.length > 0 ? getDefinitionByName( type ) as Class : null;
		}
		
		public static function findMetadataByName( bean:Object, metadataName:String, metadataClass:Class ):Array
		{
			return findClassMetadataByName( getDefinitionByName( getQualifiedClassName( bean ) ) as Class, metadataName, metadataClass );
		}
		
		public static function findClassMetadataByName( type:Class, metadataName:String, metadataClass:Class ):Array
		{
			var id:String = type + metadataName + metadataClass;
			
			if ( id in metadata )
			{
				return metadata[ id ];
			}
			
			var superClassName:String = getQualifiedSuperclassName( type );
			var metadatas:Array = [];
			
			if ( superClassName != null )
			{
				var superClass:Class = getDefinitionByName( superClassName ) as Class;
				metadatas = findClassMetadataByName( superClass, metadataName, metadataClass ).concat();
			}
			
			var typeDescription:XML = getTypeDescription( type );
			var list:XMLList = typeDescription..metadata.(@name == metadataName);
			
			for each ( var item:XML in list )
			{
				metadatas[ metadata.length ] = new metadataClass( item );
			}
			
			return metadata[ id ] = metadatas;
		}
		
		public static function hasArg( metadata:XML, argName:String ):Boolean
		{
			return metadata.arg.( @key == argName ) != null && metadata.arg.( @key == argName ).@value != undefined;
		}
		
		public static function getArg( metadata:XML, argName:String ):String
		{
			return hasArg( metadata, argName ) ? metadata.arg.( @key == argName ).@value : null;
		}
		
	}
}