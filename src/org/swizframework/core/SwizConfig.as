package org.swizframework.core
{
	import flash.events.Event;
	
	import mx.logging.LogEventLevel;
	
	public class SwizConfig implements ISwizConfig
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for the <code>strict</code> property.
		 */
		protected var _strict:Boolean = false;
		
		/**
		 * Backing variable for the <code>mediateBubbledEvents</code> property.
		 */
		protected var _mediateBubbledEvents:Boolean = true;
		
		/**
		 * Backing variable for the <code>injectionEvent</code> property.
		 */
		protected var _injectionEvent:String = Event.ADDED_TO_STAGE;
		
		/**
		 * Backing variable for the <code>logEventLevel</code> property.
		 */
		protected var _logEventLevel:int = LogEventLevel.WARN;

		/**
		 * Backing variable for the <code>eventPackages</code> property.
		 */
		protected var _eventPackages:Array = [];
		
		/**
		 * Backing variable for the <code>viewPackages</code> property.
		 */
		protected var _viewPackages:Array = [];

		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function get strict():Boolean
		{
			return _strict;
		}
		
		public function set strict( value:Boolean ):void
		{
			_strict = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get mediateBubbledEvents():Boolean
		{
			return _mediateBubbledEvents;
		}
		
		public function set mediateBubbledEvents( value:Boolean ):void
		{
			_mediateBubbledEvents = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get injectionEvent():String
		{
			return _injectionEvent;
		}
		
		public function set injectionEvent( value:String ):void
		{
			_injectionEvent = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get logEventLevel():int
		{
			return _logEventLevel;
		}
		
		public function set logEventLevel( value:int ):void
		{
			_logEventLevel = value;
		}		
		
		/**
		 * @inheritDoc
		 */
		public function get eventPackages():Array
		{
			return _eventPackages;
		}
		
		public function set eventPackages( value:* ):void
		{
			setEventPackages( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get viewPackages():Array
		{
			return _viewPackages;
		}
		
		public function set viewPackages( value:* ):void
		{
			setViewPackages( value );
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function SwizConfig()
		{
			super();
		}

		// ========================================
		// protected methods
		// ========================================
		
		protected function setEventPackages( value:* ):void
		{
			_eventPackages = parsePackageValue( value );
		}

		protected function setViewPackages( value:* ):void
		{
			_viewPackages = parsePackageValue( value );
		}
		
		protected function parsePackageValue( value:* ):Array
		{
			if ( value == null )
			{
				return [];
			}
			else if ( value is Array )
			{
				return parsePackageNames( value as Array );
			}
			else if ( value is String )
			{
				return parsePackageNames( value.replace( " ", "" ).split( "," ) );
			}
			else
			{
				throw new Error( "Package specified using unknown type. Supported types are Array or String." );
			}
		}
		
		protected function parsePackageNames( packageNames:Array ):Array
		{
			var parsedPackageNames:Array = [];
			
			for each ( var packageName:String in packageNames )
			{
				parsedPackageNames.push( parsePackageName( packageName ) );
			}
			
			return parsedPackageNames;
		}
		
		protected function parsePackageName( packageName:String ):String
		{
			var wildcard:RegExp = /\A(.*)(\.\**)\Z/;
			
			if ( wildcard.test( packageName ) )
				return wildcard.exec( packageName )[ 1 ];

			return packageName;			
		}
	}
}