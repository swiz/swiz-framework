package org.swizframework.utils.commands
{
	import flash.events.Event;
	
	/**
	 * Interface that instructs a Swiz CommandMap to supply a reference to the event
	 * which triggered this command's execution.
	 * 
	 * @see org.swizframework.utils.commands.CommandMap
	 */
	public interface IEventAwareCommand extends ICommand
	{
		function set event( value:Event ):void;
	}
}