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

package org.swizframework.utils.services
{
	import flash.net.ObjectEncoding;
	
	import mx.core.ByteArrayAsset;
	import mx.messaging.messages.AcknowledgeMessage;
	
	public class AMFUtil
	{
		/**
		 * Retrieves actual AMF payload data from saved binary.
		 *
		 * @param clazz AMF data
		 * @return Actual AMF payload contents
		 */
		public static function getAMF3Data( clazz:Class ):Object
		{
			var mockData:ByteArrayAsset = ByteArrayAsset( new clazz() );
			mockData.objectEncoding = ObjectEncoding.AMF3;
			
			while( mockData.readByte() != 0x0A )
			{
				// Nothing to do
				// readByte() will auto-advance position and read the new value every iteration
			}
			mockData.position--;
			
			return AcknowledgeMessage( mockData.readObject() ).body;
		}
	}
}