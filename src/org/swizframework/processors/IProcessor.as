package org.swizframework.processors
{
	import org.swizframework.core.ISwiz;

	/**
	 * Base interface that ensures all implementers have a reference to the containing
	 * instance of <code>Swiz</code> and a <code>priority</code> to determine
	 * their place in line.
	 */
	public interface IProcessor
	{
		/**
		 * Method used to set reference to parent <code>Swiz</code> instance.
		 */
		function init( swiz:ISwiz ):void;

		/**
		 * Read-only property used to specify this processor's priority in the list of processors.
		 */
		function get priority():int;
	}
}