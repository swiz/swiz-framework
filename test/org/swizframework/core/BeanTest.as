/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package org.swizframework.core
{
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.swizframework.reflection.TypeDescriptor;

	public class BeanTest
	{
		private var bean:Bean;
		private var source:Object;
		private var name:String;
		private var typeDescriptor:TypeDescriptor;
		
		[Before]
		public function setUp():void
		{
			source = Object;
			name = "TestBean";
			typeDescriptor = new TypeDescriptor();
		}
		
		[Test]
		public function sourceGetter_constructorWithNullSource_isNull():void
		{
			bean = new Bean();
			assertNull("The source property should be null.", bean.source);
		}
		
		[Test]
		public function sourceGetter_constructorWithNonNullSource_isNotNull():void
		{
			bean = new Bean(source);
			assertNotNull("The source property should not be null.", bean.source);
		}
		
		[Test]
		public function sourceGetter_constructorWithNonNullSource_returnsCorrectSource():void
		{
			bean = new Bean(source);
			assertStrictlyEquals("The source property was not what was expected.", source, bean.source);
		}
		
		[Test]
		public function nameGetter_constructorWithNullName_isNull():void
		{
			bean = new Bean(source);
			assertNull("The name property should be null.", bean.name);
		}
		
		[Test]
		public function nameGetter_constructorWithNonNullName_isNotNull():void
		{
			bean = new Bean(source, name);
			assertNotNull("The name property should not be null.", bean.name);
		}
		
		[Test]
		public function nameGetter_constructorWithNonNullName_returnsCorrectName():void
		{
			bean = new Bean(source, name);
			assertStrictlyEquals("The name property was not what was expected.", name, bean.name);
		}
		
		[Test]
		public function typeDescriptorGetter_constructorWithNullTypeDescriptor_isNull():void
		{
			bean = new Bean(source, name);
			assertNull("The typeDescriptor property should be null.", bean.typeDescriptor);
		}
		
		[Test]
		public function typeDescriptorGetter_constructorWithNonNullTypeDescriptor_isNotNull():void
		{
			bean = new Bean(source, name, typeDescriptor);
			assertNotNull("The typeDescriptor property should not be null.", bean.typeDescriptor);
		}
		
		[Test]
		public function typeDescriptorGetter_constructorWithNonNullTypeDescriptor_returnsCorrectTypeDescriptor():void
		{
			bean = new Bean(source, name, typeDescriptor);
			assertStrictlyEquals("The typeDescriptor property was not what was expected.", typeDescriptor, bean.typeDescriptor);
		}
		
		[Test]
		public function typeGetter_constructorWithNullSource_isNull():void
		{
			bean = new Bean();
			assertNull("The type property should be null.", bean.type);
		}
		
		[Test]
		public function typeGetter_constructorWithNonNullSource_isNotNull():void
		{
			bean = new Bean(source);
			assertNotNull("The type property should not be null.", bean.type);
		}
		
		[Test]
		public function typeGetter_constructorWithNonNullSource_returnsCorrectType():void
		{
			bean = new Bean(source);
			assertStrictlyEquals("The type property was not what was expected.", source, bean.type);
		}
	}
}