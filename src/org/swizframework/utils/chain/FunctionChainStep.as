package org.swizframework.utils.chain
{
	public class FunctionChainStep extends BaseChainStep
	{
		public var functionRef:Function;
		public var functionArgArray:Array;
		public var functionThisArg:*;
		
		public function FunctionChainStep( functionRef:Function, functionArgArray:Array = null, functionThisArg:* = null )
		{
			this.functionRef = functionRef;
			this.functionArgArray = functionArgArray;
			this.functionThisArg = functionThisArg;
		}
	}
}