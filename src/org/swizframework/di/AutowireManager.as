package org.swizframework.di
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;
	
	public class AutowireManager
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * 
		 */
		protected var beans:Dictionary = new Dictionary( true );
		
		// ========================================
		// constructor
		// ========================================
		
		public function AutowireManager()
		{
			
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * 
		 */
		protected function isPotentialTarget( target:Object ):Boolean
		{
			var className:String = getQualifiedClassName( target );
			return className.indexOf( "mx." ) != 0
					&& className.indexOf( "flash." ) != 0
					&& className.indexOf( "spark." ) != 0
					&& className.indexOf( "_" ) < 0;
		}
		
		/**
		 * 
		 */
		protected function createBean( definition:XML ):Bean
		{
			var bean:Bean = new Bean();
			var node:XML;
			
			bean.type = definition.@name;
			bean.superClassType = definition.@base;
			bean.interfaces = [];
			for each( node in definition.implementsInterface )
				bean.interfaces.push( node.@type.toString() );
			
			return bean;
		}
		
		/**
		 * 
		 */
		protected function getAutowireTargets( definition:XML ):Array
		{
			var targets:XML = <targets />;
			var node:XML;
			
			// can check for Autowire directly on variables (non-bindable properties)
			targets.appendChild( definition.variable.( metadata.@name == "Autowire" ) );
			
			// get all accessors with any kind of metadata
			var accessorList:XMLList = definition.accessor.( ( @access == "readwrite" || @access == "writeonly" ) && hasOwnProperty( "metadata" ) );
			
			// have to inspect this list and make sure we only keep nodes with Autowire metadata
			for each( node in accessorList )
			{
				if( node.metadata.( @name == "Autowire" ) != undefined )
					targets.appendChild( node );
			}
			
			// create objects from the xml
			var autowireTargets:Array = [];
			var autowireTarget:AutowireMember;
			var args:Array;
			var isBindable:Boolean;
			var isWriteOnly:Boolean;
			
			for each( node in targets.children() )
			{
				args = [];
				for each( var arg:XML in node.metadata.( @name == "Autowire" ).arg )
				{
					args.push( { key: arg.@key.toString(), value: arg.@value.toString() } );
				}
				isBindable = node.metadata.( @name == "Bindable" ) != undefined;
				isWriteOnly = node.hasOwnProperty( "@access" ) && node.@access == "writeonly";
				
				autowireTargets.push( new AutowireMember( node.@name, node.@type, args, isBindable, isWriteOnly ) );
			}
			
			return autowireTargets;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function autowire( target:Object ):void
		{
			if( !isPotentialTarget( target ) )
				return;
			
			// TODO: port caching logic
			var definition:XML = describeType( target );
			//trace( definition );
			var bean:Bean = createBean( definition );
			bean.autowireMembers = getAutowireTargets( definition );
			beans[ UIDUtil.getUID( target ) ] = bean;
		}
	}
}