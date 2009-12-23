package org.swizframework.core
{
	public interface IBeanFactoryAware extends ISwizInterface
	{
		function set beanFactory( beanFactory : IBeanFactory ) : void;
	}
}