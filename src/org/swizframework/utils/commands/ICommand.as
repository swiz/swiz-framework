package org.swizframework.utils.commands
{
	/**
	 * Base interface that must be implemented in order to be mapped to an event in a CommandMap.
	 * 
	 * @see org.swizframework.utils.commands.CommandMap
	 */
	public interface ICommand
	{
		function execute():void;
	}
}