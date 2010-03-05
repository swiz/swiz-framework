package org.swizframework.metadata
{
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * Class to represent <code>[Inject]</code> metadata tags.
	 */
	public class InjectMetadataTag extends BaseMetadataTag
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for read-only <code>source</code> property.
		 */
		protected var _source:String;
		
		/**
		 * Backing variable for read-only <code>destination</code> property.
		 */
		protected var _destination:String;
		
		/**
		 * Backing variable for read-only <code>twoWay</code> property.
		 */
		protected var _twoWay:Boolean = false;
		
		/**
		 * Backing variable for read-only <code>view</code> property.
		 */
		protected var _view:Boolean = false;
		
		/**
		 * Backing variable for read-only <code>bind</code> property.
		 */
		protected var _bind:Boolean = true;
		
		/**
		 * Backing variable for read-only <code>required</code> property.
		 */
		protected var _required:Boolean = true;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Returns source attribute of [Inject] tag.
		 * Refers to the source to be used for injection.
		 * Is the default attribute, meaning <code>[Inject( "someModel" )]</code> is
		 * equivalent to <code>[Inject( source="someModel" )]</code>.
		 */
		public function get source():String
		{
			return _source;
		}
		
		public function set source( value:String ):void
		{
			_source = value;
		}
		
		/**
		 * Returns destination attribute of [Inject] tag.
		 * Refers to the injection target.
		 */
		public function get destination():String
		{
			return _destination;
		}
		
		/**
		 * Returns twoWay attribute of [Inject] tag as a <code>Boolean</code> value.
		 * If true will cause a two way binding to be established.
		 *
		 * @default false
		 */
		public function get twoWay():Boolean
		{
			return _twoWay;
		}
		
		/**
		 * Returns view attribute of [Inject] tag as a <code>Boolean</code> value.
		 * If true tells Swiz that the injection source is a view component
		 * that must be injected once it is added to the display list.
		 *
		 * @default false
		 */
		public function get view():Boolean
		{
			return _view;
		}
		
		/**
		 * Returns bind attribute of [Inject] tag as a <code>Boolean</code> value.
		 * If true will cause a binding to be established.
		 *
		 * @default true
		 */
		public function get bind():Boolean
		{
			return _bind;
		}
		
		/**
		 * Returns required attribute of [Inject] tag as a <code>Boolean</code> value.
		 * If true Swiz will throw an error if it fails to fill this dependency.
		 *
		 * @default true
		 */
		public function get required():Boolean
		{
			return _required && view == false;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor sets <code>defaultArgName</code>.
		 */
		public function InjectMetadataTag()
		{
			defaultArgName = "source";
		}
		
		// ========================================
		// public methods
		// ========================================
		
		override public function copyFrom( metadataTag:IMetadataTag ):void
		{
			super.copyFrom( metadataTag );
			
			//if( name == "Autowire" )
			// TODO: log deprecation warning
			
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
			// [Inject( "someModel" )] == [Inject( source="someModel" )]
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
			
			if( hasArg( "required" ) )
				_required = getArg( "required" ).value == "true";
		}
	}
}