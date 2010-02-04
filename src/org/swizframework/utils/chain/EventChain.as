package org.swizframework.utils.chain
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class EventChain extends AbstractChain
	{
		public function EventChain( dispatcher:IEventDispatcher, stopOnError:Boolean = true )
		{
			super( dispatcher, stopOnError );
		}
		
		/**
		 *
		 */
		override public function doProceed():void
		{
			dispatcher.dispatchEvent( Event( members[ position ] ) );
		}
	}
}