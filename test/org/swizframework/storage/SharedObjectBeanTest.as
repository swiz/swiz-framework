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

package org.swizframework.storage
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.swizframework.storage.ISharedObjectBean;
	import org.swizframework.storage.SharedObjectBean;

	public class SharedObjectBeanTest
	{
		private var _soBean:ISharedObjectBean;
		
		[Before]
		public function setUp():void
		{
			_soBean = new SharedObjectBean();
			_soBean.name = "SwizTest";
			_soBean.clear();
		}
		
		[Test]
		public function testClear():void
		{
			_soBean.setValue("Foo", "Bar");
			_soBean.clear();
			assertEquals(null, _soBean.getValue("Foo"));
		}
		
		[Test]
		public function testHasValue():void
		{
			assertEquals(false, _soBean.hasValue("Foo"));
			_soBean.setValue("Foo", "Bar");
			assertEquals(true, _soBean.hasValue("Foo"));
		}
		
		[Test]
		public function testSize():void
		{
			assertEquals(0, _soBean.size);
			_soBean.setValue("Foo", "Bar");
			assertFalse(0 == _soBean.size);
		}
		
		[Test]
		public function testValue():void
		{
			assertEquals(null, _soBean.getValue("Foo"));
			_soBean.clear();
			assertEquals("Bar", _soBean.getValue("Foo", "Bar"));
			_soBean.setValue("Foo", "Bar2");
			assertEquals("Bar2", _soBean.getValue("Foo"));
		}
		
		[Test]
		public function testString():void
		{
			assertEquals(null, _soBean.getString("Foo"));
			assertEquals("Bar", _soBean.getString("Foo", "Bar"));
			_soBean.setString("Foo", "Bar2");
			assertEquals("Bar2", _soBean.getString("Foo"));
		}
		
		[Test]
		public function testBoolean():void
		{
			assertEquals(false, _soBean.getBoolean("Foo"));
			_soBean.clear();
			assertEquals(true, _soBean.getBoolean("Foo", true));
			_soBean.setBoolean("Foo", true);
			assertEquals(true, _soBean.getBoolean("Foo"));
		}
		
		[Test]
		public function testNumber():void
		{
			assertTrue(isNaN(_soBean.getNumber("Foo")));
			_soBean.clear();
			assertEquals(1.5, _soBean.getNumber("Foo", 1.5));
			_soBean.setNumber("Foo", 2.5);
			assertEquals(2.5, _soBean.getNumber("Foo"));
		}
		
		[Test]
		public function testInt():void
		{
			assertEquals(-1, _soBean.getInt("Foo"));
			_soBean.clear();
			assertEquals(1, _soBean.getNumber("Foo", 1));
			_soBean.setNumber("Foo", 2);
			assertEquals(2, _soBean.getNumber("Foo"));
		}
	
	}
}