package org.swizframework.reflection
{
	/**
	 * Representation of a property that has been decorated with metadata.
	 */
	public class BindableMetadataHost extends BaseMetadataHost
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
		
		public function BindableMetadataHost()
		{
			super();
		}
	}
}