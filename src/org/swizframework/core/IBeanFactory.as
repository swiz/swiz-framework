package org.swizframework.core
{
	/**
	 * Bean Factory Interface
	 */
	public interface IBeanFactory
	{
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * Called by Swiz
		 */
		function init( swiz:ISwiz ):void;
		function setUpBeans():void;
		function setUpBean( bean:Bean ):void;
		
		/**
		 * Parent Swiz instance, for nesting and modules
		 */
		function get parentBeanFactory():IBeanFactory;
		function set parentBeanFactory( parentBeanFactory:IBeanFactory ):void;
		
		/**
		 * Maybe better to extend bean provider interface
		 */
		function getBeanByName( name:String ):Bean;
		function getBeanByType( type:Class ):Bean;
		
		function get beans():Array;
		
		function tearDown():void;
	}
}