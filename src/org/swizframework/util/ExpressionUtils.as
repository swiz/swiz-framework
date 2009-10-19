package org.swizframework.util {
	import flash.utils.getDefinitionByName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import org.swizframework.Swiz;
	import org.swizframework.error.ExpressionError;
	import org.swizframework.factory.BeanFactory;
	
	public class ExpressionUtils {
		private static const logger : ILogger = Log.getLogger( "ExpressionUtils" );
		
		public static function evaluate( expression : String ) : * {
			
			// let's just make sure this is a valid expression...
			if ( !expression.substr( 0, 2 ) == "${" || !expression.charAt( expression.length - 1 ) == "}" )
				throw new ExpressionError( "Invalid Expression! Swiz expressions must be in the format '${foo.bar}'!" );
			
			if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "retrieved expression: {0}", expression );
			
			// truncate the parts we don't need
			var expString : String = expression.substr( 2, expression.length - 3 );
			if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "truncated expression: {0}", expString );
			
			// split up the expression
			var arr : Array = expString.split( "." );
			
			// so the first item should be a bean (unless it is 'this', to come...)
			if ( !Swiz.containsBean( arr[ 0 ] ) )
				throw new ExpressionError( "Error evaluating expression " + expression + ". Bean " + arr[ 0 ] + " not found." );
			
			var obj : Object = Swiz.getBean( arr[ 0 ] );
			var tmp : Object;
			
			// we are going to just walk down the expression looking for values. there will 
			// be errors here if things are not just right. we can make some readable errors to 
			// make things a lot nicer...
			var prop : String;
			if ( arr.length > 1 ) {
				for ( var i : int = 1; i<arr.length; i++ ) {
					prop = arr[ i];
					try {
						if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
							logger.info( "looking for property, could be static" );
						obj = obj[ prop ];
					} catch ( e : ReferenceError ) {
						if ( Swiz.hasLogLevel( LogEventLevel.WARN ) )
							logger.warn( "could not retrieve property, could be static" );
						var desc : XML = BeanFactory.getBeanDescription( obj );
						var clazz : * = getDefinitionByName( desc.@name );
						obj = clazz[ prop ];
						// with static members, there will be no reference error, obj is now null...
						if ( clazz[ prop ] != null )
							obj = clazz[ prop ];
						else
							throw new ExpressionError( "Error evaluating expression " + expression + ". Property " + prop + " not found." );
					}
					/*
					   tmp = findPublic(obj, prop);
					   if (tmp != null) {
					   obj = tmp
					   } else {
					   obj = findStatuc(obj, prop);
					   }
					 */
				}
				return obj;
			} else {
				return obj;
			}
		}
		
		private static function findPublic( obj : Object, prop : String ) : Object {
			try {
				if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "fetching public property..." );
				return obj[ prop ];
			} catch ( e : ReferenceError ) {
				if ( Swiz.hasLogLevel( LogEventLevel.WARN ) )
					logger.warn( "{} not found", prop );
			}
			return null;
		}
		
		private static function findStatuc( obj : Object, prop : String ) : Object {
			try {
				if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
					logger.info( "fetching static property..." );
				var desc : XML = BeanFactory.getBeanDescription( obj );
				var clazz : * = getDefinitionByName( desc.@name );
				return clazz[ prop ];
			} catch ( e : ReferenceError ) {
				if ( Swiz.hasLogLevel( LogEventLevel.WARN ) )
					logger.warn( prop + " not found" );
			}
			return null;
		}
	}
}