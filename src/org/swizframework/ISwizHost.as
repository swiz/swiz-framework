package org.swizframework
{
	/**
	 * Interface that IEventDispatchers can optionally implement
	 * when serving as the host for a Swiz instance. Useful if
	 * direct access to the Swiz instance is desired or necessary.
	 */
	public interface ISwizHost
	{
		function get swizInstance():Swiz;
		function set swizInstance( value:Swiz ):void;
	}
}