package org.swizframework.factory {
	
	public interface IMetadataAwareBean {
		/**
		 *
		 * @return Array of metadata names in which the bean is interested in
		 *
		 */
		function getInterestedMetadata() : Array;
		
		/**
		 *
		 * @param md Bean XML description
		 * @param obj Bean containing an interested metadata
		 *
		 */
		function processMetadata( md : XML, obj : Object ) : void;
	}
}