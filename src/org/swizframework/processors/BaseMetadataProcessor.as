package org.swizframework.processors
{
	import flash.events.EventDispatcher;

	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;

	/**
	 * Metadata Processor
	 */
	public class BaseMetadataProcessor extends EventDispatcher implements IMetadataProcessor
	{
		// ========================================
		// protected properties
		// ========================================

		protected var swiz:ISwiz;
		protected var _metadataNames:Array;
		protected var _metadataClass:Class;

		// ========================================
		// public properties
		// ========================================

		/**
		 * @inheritDoc
		 */
		public function get metadataNames():Array
		{
			return _metadataNames;
		}

		/**
		 * @inheritDoc
		 */
		public function get metadataClass():Class
		{
			return _metadataClass;
		}

		/**
		 *
		 */
		public function get priority():int
		{
			return ProcessorPriority.DEFAULT;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor
		 */
		public function BaseMetadataProcessor( metadataNames:Array, metadataClass:Class = null )
		{
			super();

			this._metadataNames = metadataNames;
			this._metadataClass = metadataClass;
		}

		// ========================================
		// public methods
		// ========================================

		/**
		 * @inheritDoc
		 */
		public function init( swiz:ISwiz ):void
		{
			this.swiz = swiz;
		}

		/**
		 * @inheritDoc
		 */
		public function setUpMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			var metadataTag:IMetadataTag;

			if( metadataClass != null )
			{
				for( var i:int = 0; i < metadataTags.length; i++ )
				{
					metadataTag = metadataTags[ i ] as IMetadataTag;
					metadataTags.splice( i, 1, createMetadataTag( metadataTag ) );
				}
			}

			for each( metadataTag in metadataTags )
			{
				setUpMetadataTag( metadataTag, bean );
			}
		}

		public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			// empty, subclasses should override
		}

		/**
		 * @inheritDoc
		 */
		public function tearDownMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			var metadataTag:IMetadataTag;

			if( metadataClass != null )
			{
				for( var i:int = 0; i < metadataTags.length; i++ )
				{
					metadataTag = metadataTags[ i ] as IMetadataTag;
					metadataTags.splice( i, 1, createMetadataTag( metadataTag ) );
				}
			}

			for each( metadataTag in metadataTags )
			{
				tearDownMetadataTag( metadataTag, bean );
			}
		}

		public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			// empty, subclasses should override
		}

		protected function createMetadataTag( metadataTag:IMetadataTag ):IMetadataTag
		{
			var tag:IMetadataTag = new metadataClass();
			tag.copyFrom( metadataTag );
			return tag;
		}
	}
}