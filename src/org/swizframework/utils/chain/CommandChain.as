package org.swizframework.utils.chain
{
	public class CommandChain extends AbstractChain
	{
		public function CommandChain( stopOnError:Boolean = true, mode:String = AbstractChain.SEQUENCE )
		{
			super( null, stopOnError, mode );
		}
		
		/**
		 *
		 */
		override public function doProceed():void
		{
			ChainStepCommand( members[ position ] ).execute();
		}
	}
}