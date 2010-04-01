package org.swizframework.utils.chain
{
	import flash.events.IEventDispatcher;
	
	public interface IChain
	{
		function get dispatcher():IEventDispatcher;
		function set dispatcher( value:IEventDispatcher ):void;
		
		function get position():int;
		function set position( value:int ):void;
		
		function get isComplete():Boolean;
		
		function get stopOnError():Boolean;
		function set stopOnError( value:Boolean ):void;
		
		function hasNext():Boolean;
		function stepComplete():void;
		function stepError():void;
		
		function addMember( member:IChainMember ):IChain;
		function doProceed():void;
	}
}