package org.swizframework.utils.chain
{
	import flash.events.IEventDispatcher;
	
	public class CommandChain extends AbstractChain
	{
		public function CommandChain( dispatcher:IEventDispatcher, stopOnError:Boolean = true, mode:int = AbstractChain.SEQUENCE )
		{
			super( dispatcher, stopOnError, mode );
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