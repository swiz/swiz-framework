package org.swizframework.metadata
{
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataHost;
	import org.swizframework.reflection.IMetadataTag;

	/**
	 * Class to represent <code>[PostConstruct]</code> metadata tags.
	 */
	public class PostConstructMetadataTag extends BaseMetadataTag
	{
		// ========================================
		// protected properties
		// ========================================

		/**
		 * Backing variable for read-only <code>order</code> property.
		 */
		protected var _order:int = 1;

		// ========================================
		// public properties
		// ========================================

		/**
		 * Returns order attribute of [PostConstruct] tag.
		 * Refers to the order in which the decorated methods will be executed.
		 * Is the default attribute, meaning <code>[PostConstruct( 2 )]</code> is
		 * equivalent to <code>[PostConstruct( order="2" )]</code>.
		 */
		public function get order():int
		{
			return _order;
		}

		// ========================================
		// constructor
		// ========================================

		/**
		 * Constructor sets <code>defaultArgName</code>.
		 */
		public function PostConstructMetadataTag()
		{
			defaultArgName = "order";
		}

		// ========================================
		// public methods
		// ========================================

		override public function copyFrom( metadataTag:IMetadataTag ):void
		{
			super.copyFrom( metadataTag );

			if( hasArg( "order" ) )
				_order = int( getArg( "order" ).value );
		}
	}
}