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
			
			var child : *;
			var bean : Bean;
			var beans : Array = new Array();
			var name : String;
			
			for ( var i : uint = 0; i<accessors.length(); i++ ) {
				name = accessors[ i ];
				if (name != "beans") {
					
					// BeanProvider will take care of setting the type descriptor, 
					// but we want to wrap the intances in Bean classes to set the Bean.name to id
					child = this[ name ];
					
					if (child is Bean) {
						bean = Bean(child);
					} else {
						bean = new Bean();
						if ("id" in child)
							bean.name = child.id;
						bean.source = child;
					}
					
					beans.push(bean);
				}
			}
			return beans;
		}
		
	}
}