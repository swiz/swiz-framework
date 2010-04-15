package org.swizframework.utils.chain
{
	public class CommandChain extends AbstractChain implements IChain
	{
		public function CommandChain( stopOnError:Boolean = true, mode:String = ChainType.SEQUENCE )
		{
			super( null, stopOnError, mode );
		}
		
		/**
		 *
		 */
		public function doProceed():void
		{
			CommandChainStep( members[ position ] ).execute();
		}
	}
}