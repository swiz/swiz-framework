package org.swizframework.factory {
	
	/**
	 * Any object placed in a BeanLoader wich implements IInitializingBean will
	 * have initialize() called on it AFTER autowiring.
	 */
	public interface IInitializingBean {
		function initialize() : void;
	}
}