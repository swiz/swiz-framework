package org.swizframework.processors
{
	/**
	 * The ProcessorPriority class defines constant values for the <code>priority</code> property of <code>IProcessor</code> instances.
	 *
	 * <p>The higher the number, the higher the priority of the processor. All processors with priority N will be executed before
	 * processors with priority N - 1. If two or more processors share the same priority, they are processed in the order in
	 * which they were added.</p>
	 *
	 * <p>Priorities can be positive, 0, or negative. The default priority is 500.</p>
	 *
	 * <p>You should not write code that depends on the numeric values of these constants. They are subject to change in future versions of Swiz.</p>
	 */
	public final class ProcessorPriority
	{
		/**
		 * Built-in <code>OutjectProcessor</code> is the first native processor run to ensure
		 * items decorated with <code>[Outject]</code> are made available for injection.
		 *
		 * @see org.swizframework.processors.ComponentProcessor
		 */
		public static const OUTJECT			:int = 100;
		
		/**
		 * Built-in <code>InjectProcessor</code> is the second native processor run to
		 * satisfy declared dependencies in any beans/components provided to Swiz.
		 *
		 * @see org.swizframework.processors.InjectProcessor
		 */
		public static const INJECT			:int = 200;
		
		/**
		 * Built-in <code>PostConstructProcessor</code> runs after <code>InjectProcessor</code>
		 * to allow components to do any necessary initialization once their dependencies have been satisfied.
		 *
		 * @see org.swizframework.processors.InjectProcessor
		 */
		public static const POST_CONSTRUCT	:int = 300;
		
		/**
		 * Built-in <code>MediateProcessor</code> uses this priority.
		 *
		 * @see org.swizframework.processors.MediateProcessor
		 */
		public static const MEDIATE			:int = 400;
		
		/**
		 * Default priority used by <code>BaseMetadataProcessor</code>.
		 *
		 * @see org.swizframework.processors.BaseMetadataProcessor
		 */
		public static const DEFAULT			:int = 500;
	}
}