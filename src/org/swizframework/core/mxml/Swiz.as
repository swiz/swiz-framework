package org.swizframework.core.mxml
{
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	
	import org.swizframework.core.IBeanFactory;
	import org.swizframework.util.SwizLogger;
	
	[DefaultProperty( "beanProviders" )]
	
	/**
	 * Core framework class that serves as an IoC container rooted
	 * at the IEventDispatcher passed into its constructor.
	 */
	public class Swiz extends org.swizframework.core.Swiz implements IMXMLObject
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * 
		 */
		protected static var logger:ILogger = SwizLogger.getLogger( Swiz );
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function Swiz( dispatcher:IEventDispatcher = null, beanFactory:IBeanFactory = null, beanProviders:Array = null, customProcessors:Array = null )
		{
			super( dispatcher, beanFactory, beanProviders, customProcessors );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @see mx.core.IMXMLObject#initialized
		 */
		public function initialized( document:Object, id:String ):void
		{
			if ( document is IEventDispatcher && dispatcher == null )
			{
				dispatcher = IEventDispatcher( document );
			}
			
			// hack to delay call to init() to the next frame
			// because Flex sucks
			// ( complex objects/bound properties that are set as attributes are still null right now )
			var t:Timer = new Timer( 0, 1 );
			t.addEventListener( TimerEvent.TIMER, 
			
				function( e:TimerEvent ):void
				{
					e.currentTarget.removeEventListener( e.type, arguments.callee );
					init();
				}
				
			);
			t.start();
		}
	}
}
