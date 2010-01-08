package org.swizframework.reflection
{
	/**
	 * Base implementation of the IMetadataTag interface.
	 * Implements getters and setters, <code>hasArg</code> and <code>getArg</code>
	 * methods. Also adds <code>defaultArgName</code> support and defines
	 * <code>asString</code> method for reconstructing the tag as it
	 * looks in the source code (mostly for debugging purposes).
	 */
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
		 * @inheritDoc
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
		 * @inheritDoc
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
		 * @inheritDoc
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
		 * Name that will be assumed/used when a default argument value is provided,
		 * e.g. [Autowire( "someModel" )]
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
		
		/**
		 * Constructor sets initial values of required parameters.
		 * 
		 * @param name
		 * @param args
		 * @param host
		 * @param defaultArgName
		 */		
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
		
		/**
		 * @inheritDoc
		 */
		public function hasArg( argName:String ):Boolean
		{
			for each( var arg:MetadataArg in args )
			{
				if( arg.key == argName || ( arg.key == "" && argName == defaultArgName ) )
					return true;
			}
			
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
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
		
		/**
		 * Utility method useful for development and debugging 
		 * that returns string showing what this tag looked like defined in code.
		 * 
		 * @return String representation of this tag as it looks in code.
		 */		
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