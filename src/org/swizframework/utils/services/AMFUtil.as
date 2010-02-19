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