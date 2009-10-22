package org.swizframework.di
{
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
		public var autowireMembers:Array;
		
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
			this.description = description;
			this.className = description.@name;
			trace( "TypeDescriptor created for", this.className );
			this.superClassName = description.@base;
			for each( var node:XML in description.implementsInterface )
				interfaces.push( node.@type.toString() );
			this.autowireMembers = getAutowireMembers( description );
			
			return this;
		}
		
		protected function getAutowireMembers( description:XML ):Array
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
			var autowireMembers:Array = [];
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
				
				autowireMembers.push( new AutowireMember( node.@name, node.@type, args, isBindable, isWriteOnly ) );
				trace( "AutowireMember for", node.@name, "property found on TypeDescriptor for", className );
			}
			
			return autowireMembers;
		}
	}
}