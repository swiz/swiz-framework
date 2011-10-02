package org.swizframework.mediation
{
	public class ViewMediatorMapping extends MediatorMapping
	{
		public function ViewMediatorMapping( viewType:Class = null, mediatorType:Class = null )
		{
			this.viewType = viewType;
			super( matcher, mediatorType );
		}
		
		protected var _viewType:Class;
		
		public function get viewType():Class
		{
			return _viewType;
		}
		
		public function set viewType( value:Class ):void
		{
			_viewType = value;
			
			matcher = new SimpleTypeMatcher( value );
		}
	}
}