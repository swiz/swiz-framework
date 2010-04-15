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

package org.swizframework.metadata
{
	import org.swizframework.core.Bean;
	
	/**
	 * Represents a deferred request for injection.
	 */
	public class Injection
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * The corresponding [Inject] tag.
		 */
		public var injectTag:InjectMetadataTag;
		
		/**
		 * The object that contains the [Inject] tag.
		 */
		public var bean:Bean;
		
		// ========================================
		// constructor
		// ========================================
		
		public function Injection( injectTag:InjectMetadataTag = null, bean:Bean = null )
		{
			super();
			
			this.injectTag = injectTag;
			this.bean = bean;
		}
	}
}