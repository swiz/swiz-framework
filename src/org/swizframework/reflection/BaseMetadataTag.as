package org.swizframework.reflection
{
	public class BaseMetadataTag implements IMetadataTag
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>name</code> getter/setter.
		 */
		protected var _name:String;
		
		/**
		 * Backing variable for <code>args</code> getter/setter.
		 */
		protected var _args:Array;
		
		/**
		 * Backing variable for <code>host</code> getter/setter.
		 */
		protected var _host:IMetadataHost;
		
		/**
		 * Backing variable for <code>defaultArgName</code> getter/setter.
		 */
		protected var _defaultArgName:String;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * 
		 */
		public function get name():String
		{
			return _name;
		}
		
		public function set name( value:String ):void
		{
			_name = value;
		}
		
		[ArrayElementType( "org.swizframework.reflection.MetadataArg" )]
		
		/**
		 * 
		 */
		public function get args():Array
		{
			return _args;
		}
		
		public function set args( value:Array ):void
		{
			_args = value;
		}
		
		/**
		 * 
		 */
		public function get host():IMetadataHost
		{
			return _host;
		}
		
		public function set host( value:IMetadataHost ):void
		{
			_host = value;
		}
		
		/**
		 * 
		 */
		public function get defaultArgName():String
		{
			return _defaultArgName;
		}
		
		public function set defaultArgName( value:String ):void
		{
			_defaultArgName = value;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function BaseMetadataTag( name:String, args:Array, host:IMetadataHost, defaultArgName:String = null )
		{
			this.name = name;
			this.args = args;
			this.host = host;
			this.defaultArgName = defaultArgName;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		public function hasArg( argName:String ):Boolean
		{
			for each( var arg:MetadataArg in args )
			{
				if( arg.key == argName || ( arg.key == "" && argName == defaultArgName ) )
					return true;
			}
			
			return false;
		}
		
		public function getArg( argName:String ):MetadataArg
		{
			for each( var arg:MetadataArg in args )
			{
				if( arg.key == argName || ( arg.key == "" && argName == defaultArgName ) )
					return arg;
			}
			
			// TODO: throw error
			return null;
		}
		
		public function get asString():String
		{
			var str:String = "[" + name;
			
			if( args != null && args.length > 0 )
			{
				str += "( ";
				for( var i:int = 0; i < args.length; i++ )
				{
					var arg:MetadataArg = args[ i ];
					
					str += arg.key + "=\"" + arg.value + "\"";
					
					if( i + 1 < args.length )
						str += ", ";
				}
				str += " )";
			}
			
			str += "]";
			return str;
		}
	}
}