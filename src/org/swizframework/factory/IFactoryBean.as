package org.swizframework.factory {
	import flash.utils.Dictionary;
	
	public interface IFactoryBean {
		function getObject() : *;
		function getObjectType() : String;
		function getObjectDescription() : XML;
	}
}