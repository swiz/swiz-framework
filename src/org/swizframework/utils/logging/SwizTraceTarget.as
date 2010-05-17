package org.swizframework.utils.logging
{	
	public class SwizTraceTarget extends AbstractSwizLoggingTarget
	{
		public function SwizTraceTarget()
		{
		}
		
		/** subclasses must override! */
		override protected function logEvent( event:SwizLogEvent ):void
		{
			// prepare message [] format...
			traceMessage( event.message );	
		}
		
		private function traceMessage(message:String):void
		{
			trace(message);
		}
	}
}