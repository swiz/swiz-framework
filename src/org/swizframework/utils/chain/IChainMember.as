package org.swizframework.utils.chain
{
	public interface IChainMember
	{
		function get isComplete():Boolean;
		
		function get chain():IChain;
		function set chain( value:IChain ):void;
	}
}