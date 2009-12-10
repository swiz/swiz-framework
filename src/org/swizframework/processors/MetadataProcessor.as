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
		protected var _metadataName:String;
		protected var _metadataClass:Class;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		public function get metadataName():String
		{
			return _metadataName;
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
		public function MetadataProcessor( metadataName:String, metadataClass:Class = null, addMethod:Function = null, removeMethod:Function = null )
		{
			super();
			
			this._metadataName = metadataName;
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
		public function addMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			addMethod( bean, metadata );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeMetadata( bean:Bean, metadata:IMetadataTag ):void
		{
			removeMethod( bean, metadata );
		}
		
	}
}