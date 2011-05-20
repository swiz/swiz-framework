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
	import flash.utils.Dictionary;
	
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;

	/**
	 * PostConstruct Processor
	 */
	public class ViewProcessor extends BaseMetadataProcessor implements IBeanProcessor
	{
		// ========================================
		// protected static constants
		// ========================================

		protected static const VIEW_ADDED:String = "ViewAdded";
		protected static const VIEW_REMOVED:String = "ViewRemoved";
		
		// ========================================
		// protected properties
		// ========================================
		
		protected var views:Dictionary = new Dictionary();

		// ========================================
		// public properties
		// ========================================

		/**
		 *
		 */
		override public function get priority():int
		{
			return 100;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor
		 */
		public function ViewProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ VIEW_ADDED, VIEW_REMOVED ] : metadataNames );
		}

		// ========================================
		// public methods
		// ========================================
		
		/**
		 * This method is called whenever a bean is added that contains [ViewAdded]
		 * and/or [ViewRemoved] tags. These will/should be regular beans defined
		 * in a BeanProvider that want to be notified when a particular type of view
		 * is set up or torn down, respectively.
		 */
		override public function setUpMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			// parse any [ViewAdded] and [ViewRemoved] tags found
			for each ( var tag:IMetadataTag in metadataTags )
			{
				var viewType:Class;
				
				// get the view type by examining the metadata host on which the tag was declared
				if( tag.host is MetadataHostMethod )
					viewType = MethodParameter( MetadataHostMethod( tag.host ).parameters[ 0 ] ).type;
				else
					viewType = tag.host.type;
				
				// make sure there is an array for this view type
				views[ viewType ] ||= [];
				var arr:Array = views[ viewType ] as Array;
				// store a ref
				arr.push( new ViewRef( tag, bean.source ) );
			}
		}
		
		/**
		 * This method is called whenever a bean that contains [ViewAdded]
		 * and/or [ViewRemoved] tags is torn down. This would likely only
		 * happen if the bean (mediator) was part of a module that was torn down.
		 */
		override public function tearDownMetadataTags( metadataTags:Array, bean:Bean ):void
		{
			// parse any [ViewAdded] and [ViewRemoved] tags found
			for each ( var tag:IMetadataTag in metadataTags )
			{
				var viewType:Class;
				
				// get the view type by examining the metadata host on which the tag was declared
				if( tag.host is MetadataHostMethod )
					viewType = MethodParameter( MetadataHostMethod( tag.host ).parameters[ 0 ] ).type;
				else
					viewType = tag.host.type;
				
				var arr:Array = views[ viewType ] as Array;
				
				for( var i:int = arr.length - 1; i > -1; i-- )
				{
					var ref:ViewRef = arr[ i ];
					
					if( ref.mediator === bean.source )
						arr.splice( i, 1 );
				}
			}
		}
		
		/**
		 * Called when a view is added to stage.
		 */
		public function setUpBean( bean:Bean ):void
		{
			processViewBean( bean, VIEW_ADDED );
		}
		
		/**
		 * Called when a view is removed from stage.
		 */
		public function tearDownBean( bean:Bean ):void
		{
			processViewBean( bean, VIEW_REMOVED );
		}
		
		/**
		 * Examine stored refs to see if any mediators have registered to
		 * be notified when a view of this type has been added or removed.
		 */
		protected function processViewBean( bean:Bean, tagName:String ):void
		{
			var viewType:Class = bean.typeDescriptor.type;
			
			// check for any stored refs for this view type
			if( views[ viewType ] )
			{
				var refs:Array = views[ viewType ] as Array;
				
				for each( var ref:ViewRef in refs )
				{
					if( ref.tag.name != tagName )
						continue;
					
					// if [ViewAdded] was declared on a method we pass the view in as the only argument
					if( ref.tag.host is MetadataHostMethod )
					{
						var f:Function = ref.mediator[ ref.tag.host.name ] as Function;
						f.apply( null, [ bean.source ] );
					}
					else // if [ViewAdded] was declared on a property do a simple assignment
					{
						ref.mediator[ ref.tag.host.name ] = bean.source;
					}
				}
			}
		}
	}
}

import org.swizframework.reflection.IMetadataTag;

class ViewRef
{
	public var tag:IMetadataTag;
	public var mediator:*;
	
	public function ViewRef( tag:IMetadataTag, mediator:* )
	{
		this.tag = tag;
		this.mediator = mediator;
	}
}