package org.swizframework.reflection
{
	import flash.utils.getDefinitionByName;
	
	/**
	 * Representation of a property that has been decorated with metadata.
	 */
	public class MetadataHostProperty extends BaseMetadataHost
	{
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * @return Flag indicating whether or not this property has been made bindable.
		 */		
		public function get isBindable():Boolean
		{
			for each( var tag:IMetadataTag in metadataTags )
			{
				if( tag.name == "Bindable" )
					return true;
			}
			
			return false;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor sets <code>type</code> property based on value found in <code>hostNode</code> XML node.
		 * 
		 * @param hostNode XML node from <code>describeType</code> output that represents this property.
		 */		
		public function MetadataHostProperty( hostNode:XML )
		{
			super();
			
			// Convert * type to Object class, lookup everything else
			type = hostNode.@type != "*" ? Class( getDefinitionByName( hostNode.@type ) ) : Object;
		}
	}
}