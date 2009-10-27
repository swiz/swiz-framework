package org.swizframework.di
{
	import flash.utils.Dictionary;
	
	import org.swizframework.reflect.BaseMetadataHost;
	import org.swizframework.reflect.IMetadataHost;
	import org.swizframework.reflect.MetadataArg;
	import org.swizframework.reflect.MetadataTag;
	
	public class TypeDescriptor
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public var description:XML;
		
		/**
		 * 
		 */
		public var className:String;
		
		/**
		 * 
		 */
		public var superClassName:String;
		
		/**
		 * 
		 */
		public var interfaces:Array = [];
		
		/**
		 * 
		 */
		public var metadataHosts:Array;
		
		// ========================================
		// constructor
		// ========================================
		
		public function TypeDescriptor()
		{
			
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function fromXML( description:XML ):TypeDescriptor
		{
			var d:Dictionary = new Dictionary();
			var hosts:Array = [];
			var host:IMetadataHost;
			
			for each( var mdNode:XML in description..metadata )
			{
				if( d[ mdNode.parent().@name.toString() ] == null )
				{
					d[ mdNode.parent().@name.toString() ] = mdNode.parent();
					host = new BaseMetadataHost();
					host.name = mdNode.parent().@name.toString();
					
					var args:Array = [];
					for each( var argNode:XML in mdNode.arg )
					{
						args.push( new MetadataArg( argNode.@key.toString(), argNode.@value.toString() ) );
					}
					
					var mt:MetadataTag = new MetadataTag( mdNode.@name.toString(), args, host );
					host.metadataTags.push( mt );
				}
				host = null;
			}
			
			return this;
			
			this.description = description;
			this.className = description.@name;
			trace( "TypeDescriptor created for", this.className );
			this.superClassName = description.@base;
			for each( var node:XML in description.implementsInterface )
				interfaces.push( node.@type.toString() );
			this.metadataHosts = getMetadataHosts( description );
			
			return this;
		}
		
		/*
		<variable name="color" type="uint">
		  <metadata name="Autowire"/>
		</variable>
		<variable name="alphaLevel" type="Number">
		  <metadata name="Autowire">
		    <arg key="bean" value="alphaBean"/>
		  </metadata>
		</variable>
		<accessor name="someProp" access="readwrite" type="String" declaredBy="views.shapes::CircleView">
		  <metadata name="Bindable">
		    <arg key="" value="somePropChanged"/>
		  </metadata>
		  <metadata name="Autowire">
		    <arg key="bean" value="fooBean"/>
		  </metadata>
		</accessor>
		<variable name="radius" type="Number">
		  <metadata name="Autowire">
		    <arg key="bean" value="sizeModel"/>
		    <arg key="property" value="radiusSize"/>
		  </metadata>
		</variable>
		<accessor name="accessibilityImplementation" access="readwrite" type="flash.accessibility::AccessibilityImplementation" declaredBy="flash.display::InteractiveObject">
		  <metadata name="Inspectable">
		    <arg key="environment" value="none"/>
		  </metadata>
		</accessor>
		/**/
		
		protected function getMetadataHosts( description:XML ):Array
		{
			var members:XML = <members />;
			var node:XML;
			
			// can check for Autowire directly on variables (non-bindable properties)
			members.appendChild( description.variable.( metadata.@name == "Autowire" ) );
			
			// get all accessors with any kind of metadata
			var accessorList:XMLList = description.accessor.( ( @access == "readwrite" || @access == "writeonly" ) && hasOwnProperty( "metadata" ) );
			
			// have to inspect this list and make sure we only keep nodes with Autowire metadata
			for each( node in accessorList )
			{
				if( node.metadata.( @name == "Autowire" ) != undefined )
					members.appendChild( node );
			}
			
			// create objects from the xml
			var metadataHosts:Array = [];
			var autowireTarget:AutowireMember;
			var args:Array;
			var isBindable:Boolean;
			var isWriteOnly:Boolean;
			
			for each( node in members.children() )
			{
				args = [];
				for each( var arg:XML in node.metadata.( @name == "Autowire" ).arg )
				{
					args.push( { key: arg.@key.toString(), value: arg.@value.toString() } );
				}
				isBindable = node.metadata.( @name == "Bindable" ) != undefined;
				isWriteOnly = node.hasOwnProperty( "@access" ) && node.@access == "writeonly";
				
				metadataHosts.push( new AutowireMember( node.@name, node.@type, args, isBindable, isWriteOnly ) );
				trace( "AutowireMember for", node.@name, "property found on TypeDescriptor for", className );
			}
			
			return metadataHosts;
		}
	}
}