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

package testSuites
{
	import org.swizframework.reflection.ClassConstantTest;
	import org.swizframework.reflection.TypeCacheTests;
	
	[Suite]
	[RunWith( "org.flexunit.runners.Suite" )]
	public class ReflectionUnitTestsSuite
	{
		//public var typeCacheTests:TypeCacheTests;
		public var classConstantTests:ClassConstantTest;
	}
}