package org.swizframework.error {
	
	public class ExpressionError extends Error {
		public function ExpressionError( message : String = "", id : int = 0 ) {
			super( message, id );
		}
	}
}