package org.swizframework.core
{
	import flash.utils.describeType;
	
	public class BeanLoader extends BeanProvider
	{
		public function BeanLoader()
		{
			super();
		}
		
		public function initialize():void
		{
			// retrieve beans
			var beans:Array = getBeans();
			addBeans(beans);
		}
		
		/**
		 * Returns an of the beans contained in this loader.
		 *
		 * @return Array
		 */
		private function getBeans() : Array {
			var xmlDescription : XML = describeType( this );
			var accessors : XMLList = xmlDescription.accessor.( @access == "readwrite" ).@name;
			
			var beans : Array = new Array();
			var name : String;
			
			for ( var i : uint = 0; i<accessors.length(); i++ ) {
				name = accessors[ i ];
				if (name != "beans")
					beans.push( this[ name ] );
			}
			return beans;
		}
		
	}
}