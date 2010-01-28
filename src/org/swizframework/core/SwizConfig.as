package org.swizframework.core
{
	import flash.events.Event;
	import flash.events.EventPhase;
	
	public class SwizConfig implements ISwizConfig
	{
		// ========================================
		// protected static constants
		// ========================================

		/**
		 * Regular expression to evaluate a 'wildcard' (ex. 'org.swizframework.*') package description.
		 * 
		 * Matches: package.*
		 * Captures: package
 		 */
		protected static const WILDCARD_PACKAGE:RegExp = /\A(.*)(\.\**)\Z/;
		
		// ========================================
		// protected properties
		// ========================================

		/**
		 * Backing variable for the <code>strict</code> property.
		 */
		protected var _strict:Boolean = false;
		
		/**
		 * Backing variable for the <code>injectionEvent</code> property.
		 */
		protected var _injectionEvent:String = Event.ADDED_TO_STAGE;

		/**
		 * Backing variable for the <code>injectionEventPriority</code> property.
		 */
		protected var _injectionEventPriority:int = 50;
		
		/**
		 * Backing variable for the <code>injectionEventPhase</code> property.
		 */
		protected var _injectionEventPhase:uint = EventPhase.CAPTURING_PHASE;
		
		/**
		 * Backing variable for the <code>injectionMarkerFunction</code> property.
		 */
		protected var _injectionMarkerFunction:Function = null;
		
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
		public function get injectionEventPriority():int
		{
			return _injectionEventPriority;
		}
		
		public function set injectionEventPriority( value:int ):void
		{
			_injectionEventPriority = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get injectionEventPhase():uint
		{
			return _injectionEventPhase;
		}
		
		public function set injectionEventPhase( value:uint ):void
		{
			_injectionEventPhase = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get injectionMarkerFunction():Function
		{
			return _injectionMarkerFunction;
		}
		
		public function set injectionMarkerFunction( value:Function ):void
		{
			_injectionMarkerFunction = value;
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
		
		/**
		 * Internal setter for <code>eventPackages</code> property.
		 * 
		 * @param value An Array of Strings or a single String that will be split on ","
		 */
		protected function setEventPackages( value:* ):void
		{
			_eventPackages = parsePackageValue( value );
		}

		/**
		 * Internal setter for <code>viewPackages</code> property.
		 * 
		 * @param value An Array of Strings or a single String that will be split on ","
		 */
		protected function setViewPackages( value:* ):void
		{
			_viewPackages = parsePackageValue( value );
		}
		
		/**
		 * Parses a wildcard type package property value into an Array of parsed package names.
		 * 
		 * @param value An Array of Strings or a single String that will be split on ","
		 * @returns An Array of package name strings in a common format.
		 */
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
				return parsePackageNames( value.replace( /\ /g, "" ).split( "," ) );
			}
			else
			{
				throw new Error( "Package specified using unknown type. Supported types are Array or String." );
			}
		}
		
		/**
		 * Parses an array of package names.
		 * Processes the package names to a common format - removing trailing '.*' wildcard notation.
		 * 
		 * @param packageNames The package names to parse.
		 * @returns An Array of the parsed package names.
		 */
		protected function parsePackageNames( packageNames:Array ):Array
		{
			var parsedPackageNames:Array = [];
			
			for each ( var packageName:String in packageNames )
			{
				parsedPackageNames.push( parsePackageName( packageName ) );
			}
			
			return parsedPackageNames;
		}
		
		/**
		 * Parse Package Name
		 * Processes the package name to a common format - removing trailing '.*' wildcard notation.
		 * 
		 * @param packageName The package name to parse.
		 * @returns The package name with the wildcard notation stripped.
		 */
		protected function parsePackageName( packageName:String ):String
		{
			var match:Object = WILDCARD_PACKAGE.exec( packageName );
			if ( match )
				return match[ 1 ];

			return packageName;			
		}
	}
}