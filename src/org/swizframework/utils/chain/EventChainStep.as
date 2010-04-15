package org.swizframework.utils.chain
{
	import flash.events.Event;
	
	public class EventChainStep extends Event implements IChainStep
	{
		/**
		 * Backing variable for <code>chain</code> getter/setter.
		 */
		protected var _chain:IChain;
		
		/**
		 *
		 */
		public function get chain():IChain
		{
			return _chain;
		}
		
		public function set chain( value:IChain ):void
		{
			_chain = value;
		}
		
		protected var _isComplete:Boolean;
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		public function EventChainStep( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		/**
		 *
		 */
		public function complete():void
		{
			_isComplete = true;
			
			if( chain != null )
				chain.stepComplete();
		}
		
		/**
		 *
		 */
		public function error():void
		{
			if( chain != null )
				chain.stepError();
		}
		
		override public function clone():Event
		{
			return new EventChainStep( type, bubbles, cancelable );
		}
	}
}