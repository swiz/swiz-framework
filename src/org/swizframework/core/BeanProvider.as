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

package org.swizframework.core
{
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	
	[DefaultProperty( "beans" )]
	
	public class BeanProvider extends EventDispatcher implements IBeanProvider
	{
		
		// ========================================
		// private properties
		// ========================================
		
		protected var _rawBeans:Array = [];
		
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>beans</code> getter.
		 */
		protected var _beans:Array = [];
		
		
		// ========================================
		// public properties
		// ========================================
		
		[ArrayElementType( "Object" )]
		/**
		 * Beans
		 * ([ArrayElementType( "Object" )] metadata is to avoid http://j.mp/FB-12316)
		 */
		public function get beans():Array
		{
			return _beans;
		}
		
		public function set beans( value:Array ):void
		{
			if( value != null && value != _beans && value != _rawBeans )
			{
				_rawBeans = value;
			}
		/*
		   if( value != _beans )
		   {
		   // got rid of remove beans, it didn't do anything...
		   initializeBeans( value );
		   }
		 */
		}
		
		
		// ========================================
		// Constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function BeanProvider( beans:Array = null )
		{
			super();
			this.beans = beans;
		}
		
		
		// ========================================
		// public methods
		// ========================================
		
		public function initialize( domain:ApplicationDomain ):void
		{
			// first initialize, then attempt to set all bean ids
			initializeBeans( domain );
			setBeanIds( domain );
		}
		
		public function addBean( bean:Bean ):void
		{
			if( beans )
			{
				beans[ beans.length ] = bean;
			}
			else
			{
				beans = [ bean ];
			}
		
			// now initialize the bean...
		}
		
		public function removeBean( bean:Bean ):void
		{
			if( beans )
			{
				beans.splice( beans.indexOf( bean ), 1 );
			}
		
			// clean the bean?
		}
		
		
		// ========================================
		// protected methods
		// ========================================
		
		protected function initializeBeans( domain:ApplicationDomain ):void
		{
			for each( var beanSource:Object in _rawBeans )
			{
				_beans.push( BeanFactory.constructBean( beanSource, null, domain ) );
			}
		}
		
		/**
		 * Since the setter for beans should have already created Bean objects for all children,
		 * we are primarily trying to identify the id to set in the bean's name property.
		 *
		 * However, something is really wierd with using ids or not, and whether we will
		 * actually have an array of beans at this time, so if we don't find a Bean for an
		 * element we find in describeType, we create it.
		 */
		protected function setBeanIds( domain:ApplicationDomain ):void
		{
			var xmlDescription:XML = describeType( this );
			
			// all child objects
			var beanList:XMLList = xmlDescription.*.( ( localName() == "variable" || ( localName() == "accessor" && @access == "readwrite" ) ) && attribute("uri") == undefined );
			
			var child:*;
			var name:String;
			var beanId:String;
			
			var found:Boolean;
			
			for each( var node:XML in beanList ) 
			{	
				name = node.@name;
				beanId = node.localName() == "accessor" ? name : null;
				
				if( name != "beans" )
				{
					// BeanProvider will take care of setting the type descriptor, 
					// but we want to wrap the intances in Bean classes to set the Bean.name to id
					child = this[ name ];
					
					if( child != null )
					{
						found = false;
						
						// look for any bean we may already have, and set the name propery of the bean object only
						for each( var bean:Bean in beans )
						{
							if( ( bean == child ) || ( bean.type == child ) )
							{
								bean.name = beanId;
								found = true;
								break;
							}
						}
						
						// if we didn't find the bean, we need to construct it
						if( !found )
						{
							beans.push( BeanFactory.constructBean( child, beanId, domain ) );
						}
					}
				}
			}
		}
	}
}
