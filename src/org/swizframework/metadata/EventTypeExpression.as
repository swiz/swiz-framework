package org.swizframework.metadata
{
	import org.swizframework.core.ISwiz;
	import org.swizframework.reflection.ClassConstant;
	import org.swizframework.reflection.Constant;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.reflection.TypeDescriptor;

	public class EventTypeExpression
	{
		// ========================================
		// protected properties
		// ========================================

		/**
		 * Swiz instance.
		 */
		protected var swiz:ISwiz;
		
		/**
		 * Event type expression.
		 */
		protected var expression:String;
		
		/**
		 * Backing variable for <code>eventClass</code> property.
		 */
		protected var _eventClass:Class;
		
		[ArrayElementType("String")]
		/**
		 * Backing variable for <code>eventTypes</code> property.
		 */
		protected var _eventTypes:Array;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Event Class associated for this Event type expression (if applicable).
		 */
		public function get eventClass():Class
		{
			return _eventClass;
		}
		
		[ArrayElementType("String")]
		/**
		 * Event types for this Event type expression.
		 */
		public function get eventTypes():Array
		{
			return _eventTypes;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function EventTypeExpression( expression:String, swiz:ISwiz )
		{
			this.swiz = swiz;
			this.expression = expression;
			
			parse();
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Parse event type expression.
		 *
		 * Processes an event type expression into an event class and type. Accepts a String specifying either the event type
		 * (ex. 'type') or a class constant reference (ex. 'SomeEvent.TYPE').  If a class constant reference is specified,
		 * it will be evaluated to obtain its String value.  If a ".*" wildcard is specified, all constants will evaluated.
		 *
		 * Class constant references are only supported in 'strict' mode.
		 */
		protected function parse():void
		{
			if( swiz.config.strict && ClassConstant.isClassConstant( expression ) )
			{
				_eventClass = ClassConstant.getClass( swiz.domain, expression, swiz.config.eventPackages );
				
				if( expression.substr( -2 ) == ".*" )
				{
					var td:TypeDescriptor = TypeCache.getTypeDescriptor( Constant, swiz.domain );
					_eventTypes = new Array();
					for each( var constant:Constant in td.constants )
						_eventTypes.push( constant.value );
				}
				else
				{
					_eventTypes = [ ClassConstant.getConstantValue( swiz.domain, _eventClass, ClassConstant.getConstantName( expression ) ) ];
				}
			}
			else
			{
				_eventClass = null;
				_eventTypes = [ expression ];
			}
		}
	}
}