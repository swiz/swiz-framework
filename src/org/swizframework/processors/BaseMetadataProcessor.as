/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.processors
{
	import flash.events.EventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.IBeanFactory;
	import org.swizframework.core.ISwiz;
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
		protected var beanFactory:IBeanFactory;
		
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
			this.beanFactory = swiz.beanFactory;
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