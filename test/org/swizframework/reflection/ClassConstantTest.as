package org.swizframework.reflection
{
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	public class ClassConstantTest
	{
		import flexunit.framework.Assert;
		
		// ========================================
		// public constants
		// ========================================
		
		public static const BOOLEAN_CONSTANT:Boolean = false;
		public static const INT_CONSTANT:int = 1;
		public static const NUMBER_CONSTANT:Number = 3.14;
		public static const STRING_CONSTANT:String = "String";
		public static const OBJECT_CONSTANT:Object = { property: "value" };
		public static const CLASS_CONSTANT:Class = ClassConstantTest;

		// ========================================
		// public methods
		// ========================================		
		
		[Test(description="Tests isClassConstants() to ensure it correctly identifies class constants.")]
		/**
		 * Tests isClassConstants() to ensure it correctly identifies class constants.
		 */
		public function isClassConstantsCorrectlyIdentifiesClassConstants():void
		{
			Assert.assertEquals( true, ClassConstant.isClassConstant( "Event.SELECT" ) );
			Assert.assertEquals( true, ClassConstant.isClassConstant( "flash.events.Event.SELECT" ) );
			Assert.assertEquals( true, ClassConstant.isClassConstant( "com.example.application.controllers.MyController.CONSTANT" ) );

			Assert.assertEquals( false, ClassConstant.isClassConstant( "one" ) );
			Assert.assertEquals( false, ClassConstant.isClassConstant( "one.two" ) );
			Assert.assertEquals( false, ClassConstant.isClassConstant( "one.two.three" ) );
			Assert.assertEquals( false, ClassConstant.isClassConstant( "Event" ) );
			Assert.assertEquals( false, ClassConstant.isClassConstant( "CONSTANT" ) );
		}
		
		[Test(description="Tests getClassName() to ensure it returns the correct class name when given a valid class constant.")]
		/**
		 * Tests getClassName() to ensure it returns the correct class name when given a valid class constant.
		 */
		public function getClassNameReturnsCorrectClassName():void
		{
			Assert.assertEquals( "Event", ClassConstant.getClassName( "Event.SELECT" ) );
			Assert.assertEquals( "Event", ClassConstant.getClassName( "flash.events.Event.SELECT" ) );
			Assert.assertEquals( "MyController", ClassConstant.getClassName( "com.example.application.controllers.MyController.CONSTANT" ) );
		}
		
		[Test(description="Tests getConstantName() to ensure it returns the correct constant name when given a valid class constant.")]
		/**
		 * Tests getConstantName() to ensure it returns the correct constant name when given a valid class constant.
		 */
		public function getConstantNameReturnsCorrectConstant():void
		{
			Assert.assertEquals( "SELECT", ClassConstant.getConstantName( "Event.SELECT" ) );
			Assert.assertEquals( "SELECT", ClassConstant.getConstantName( "flash.events.Event.SELECT" ) );
			Assert.assertEquals( "CONSTANT", ClassConstant.getConstantName( "com.example.application.controllers.MyController.CONSTANT" ) );
		}
		
		[Test(description="Tests getConstantValue() to ensure it returns the correct constant value.")]
		/**
		 * Tests getConstantValue() to ensure it returns the correct constant value.
		 */
		public function getConstantValueReturnsCorrectValue():void
		{
			Assert.assertEquals( Event.SELECT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, Event, "SELECT" ) );
			Assert.assertEquals( Event.SELECT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, Event, "SELECT", "String" ) );

			Assert.assertEquals( BOOLEAN_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "BOOLEAN_CONSTANT", "Boolean" ) );
			Assert.assertEquals( INT_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "INT_CONSTANT", "int" ) );
			Assert.assertEquals( NUMBER_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "NUMBER_CONSTANT", "Number" ) );			
			Assert.assertEquals( STRING_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "STRING_CONSTANT", "String" ) );
			Assert.assertEquals( OBJECT_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "OBJECT_CONSTANT", "Object" ) );			
			Assert.assertEquals( CLASS_CONSTANT, ClassConstant.getConstantValue( ApplicationDomain.currentDomain, ClassConstantTest, "CLASS_CONSTANT", "Class" ) );
		}
		
		[Test(description="Tests getClass() to ensure it returns the correct Class given a class constant.")]
		/**
		 * Tests getClass() to ensure it returns the correct Class given a class constant.
		 */
		public function getClassReturnsCorrectClass():void
		{
			Assert.assertEquals( Event, ClassConstant.getClass( ApplicationDomain.currentDomain, "Event.SELECT", [ "flash.events" ] ) );
			Assert.assertEquals( Event, ClassConstant.getClass( ApplicationDomain.currentDomain, "flash.events.Event.SELECT" ) );
			Assert.assertEquals( Event, ClassConstant.getClass( ApplicationDomain.currentDomain, "flash.events.Event.SELECT", [ "flash.events" ] ) );

			Assert.assertEquals( ClassConstantTest, ClassConstant.getClass( ApplicationDomain.currentDomain, "ClassConstantTest.STRING_CONSTANT", [ "org.swizframework.reflection" ] ) );
			Assert.assertEquals( ClassConstantTest, ClassConstant.getClass( ApplicationDomain.currentDomain, "org.swizframework.reflection.ClassConstantTest.STRING_CONSTANT" ) );
			Assert.assertEquals( ClassConstantTest, ClassConstant.getClass( ApplicationDomain.currentDomain, "org.swizframework.reflection.ClassConstantTest.STRING_CONSTANT", [ "org.swizframework.reflection" ] ) );
		}
	}
}