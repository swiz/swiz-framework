package org.swizframework.utils.chain
{
	public interface IChainStep extends IChainMember
	{
		function complete():void;
		function error():void;
	}
}