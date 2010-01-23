package org.swizframework.processors
{
	import flash.events.EventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * Metadata Processor
	 */
	public class MetadataProcessor extends EventDispatcher implements IMetadataProcessor
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var swiz:ISwiz;
		protected var addMethod:Function;
		protected var removeMethod:Function;
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
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function MetadataProcessor( metadataNames:Array, metadataClass:Class = null, addMethod:Function = null, removeMethod:Function = null )
		{
			super();
			
			this._metadataNames = metadataNames;
			this._metadataClass = metadataClass ||= BaseMetadataTag;
			
			this.addMethod = addMethod;
			this.removeMethod = removeMethod;
			
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
		public function addMetadata( metadataTag:IMetadataTag, bean:Bean ):void
		{
			addMethod( metadataTag, bean );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeMetadata( metadataTag:IMetadataTag, bean:Bean ):void
		{
			removeMethod( metadataTag, bean );
		}
	}
}