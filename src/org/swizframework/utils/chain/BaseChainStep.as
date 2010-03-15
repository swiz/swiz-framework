package org.swizframework.utils.chain
{
	public class BaseChainStep implements IChainStep
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
		
		protected var _isComplete:Boolean = false;
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		public function BaseChainStep()
		{
		
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
	}
}