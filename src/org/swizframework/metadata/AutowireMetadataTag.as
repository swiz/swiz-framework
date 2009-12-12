package org.swizframework.metadata
{
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;

	public class AutowireMetadataTag extends BaseMetadataTag
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * 
		 */
		protected var _source:String;
		
		/**
		 * 
		 */
		protected var _destination:String;
		
		/**
		 * 
		 */
		protected var _twoWay:Boolean = false;
		
		/**
		 * 
		 */
		protected var _view:Boolean = false;
		
		/**
		 * 
		 */
		protected var _bind:Boolean = true;
		
		/**
		 * 
		 */
		protected var _lazy:Boolean = true;
		
		// ========================================
		// public properties
		// ========================================
		
		public function get source():String
		{
			return _source;
		}
		
		public function get destination():String
		{
			return _destination;
		}
		
		public function get twoWay():Boolean
		{
			return _twoWay;
		}
		
		public function get view():Boolean
		{
			return _view;
		}
		
		public function get bind():Boolean
		{
			return _bind;
		}
		
		public function get lazy():Boolean
		{
			return _lazy;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function AutowireMetadataTag( args:Array, host:IMetadataHost )
		{
			super( "Autowire", args, host, "source" );
			parse();
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * 
		 */
		protected function parse():void
		{
			//if( hasArg( "bean" ) && hasArg( "source" ) )
				// TODO: throw error. use one or the other
			
			//if( hasArg( "property" ) )
				// TODO: throw error. no longer supported.
			
			if( hasArg( "bean" ) )
			{
				// TODO: log deprecation message
				_source = getArg( "bean" ).value;
			}
			
			// source is the default attribute
			// [Autowire( "appModel" )] == [Autowire( source="appModel" )]
			if( hasArg( "source" ) )
				_source = getArg( "source" ).value;
			
			if( hasArg( "destination" ) )
				_destination = getArg( "destination" ).value;
			
			if( hasArg( "twoWay" ) )
				_twoWay = getArg( "twoWay" ).value == "true";
			
			if( hasArg( "view" ) )
				_view = getArg( "view" ).value == "true";
			
			if( hasArg( "bind" ) )
				_bind = getArg( "bind" ).value == "true";
			
			if( hasArg( "lazy" ) )
				_lazy = getArg( "lazy" ).value == "true";
		}
	}
}