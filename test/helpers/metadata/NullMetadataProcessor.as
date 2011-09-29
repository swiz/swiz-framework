package helpers.metadata
{
	import org.swizframework.core.Bean;
	import org.swizframework.processors.BaseMetadataProcessor;
	import org.swizframework.reflection.IMetadataTag;
	
	/**
	 * NullMetadataProcessor is a BaseMetadataProcessor subclass that implements the abstract
	 * functions from the base class. The purpose of this class is to test the base class
	 * behavior by gathering data about the base class functions that delegate to subclass functions.
	 * 
	 * @author Jeff Roberts
	 */
	public class NullMetadataProcessor extends BaseMetadataProcessor
	{
		//------------------------------------------------------
		//
		// Properties
		//
		//------------------------------------------------------
		
		//------------------------------------------------------
		// validateMetadataTagInvocationCount
		//------------------------------------------------------
		
		/**
		 * @private
		 * A count of the number of times the validateMetadataTag function was invoked.
		 */
		private var _validateMetadataTagInvocationCount:int;
		
		/**
		 * Answer the validateMetadataTag invocation count
		 */
		public function get validateMetadataTagInvocationCount():int
		{
			return _validateMetadataTagInvocationCount;
		}
		
		//------------------------------------------------------
		// setupMetadataTagInvocationCount
		//------------------------------------------------------
		
		/**
		 * @private
		 * A count of the number of times the setupMetadataTag function was invoked.
		 */
		private var _setupMetadataTagInvocationCount:int;
		
		/**
		 * Answer the setupMetadataTag invocation count
		 */
		public function get setupMetadataTagInvocationCount():int
		{
			return _setupMetadataTagInvocationCount;
		}
		
		//------------------------------------------------------
		// tearDownMetadataTagInvocationCount
		//------------------------------------------------------
		
		/**
		 * @private
		 * The count of the number of times the tearDownMetadatTag function was invoked.
		 */
		private var _tearDownMetadataTagInvocationCount:int;
		
		/**
		 * Answer the tearDownMetdataTag invocation count
		 */
		public function get tearDownMetadataTagInvocationCount():int
		{
			return _tearDownMetadataTagInvocationCount;
		}
		
		//------------------------------------------------------
		//
		// Constructor
		//
		//------------------------------------------------------
		
		public function NullMetadataProcessor(metadataNames:Array, metadataClass:Class=null)
		{
			super(metadataNames, metadataClass);
		}
		
		//------------------------------------------------------
		//
		// Public API
		//
		//------------------------------------------------------
		
		override public function setUpMetadataTag(metadataTag:IMetadataTag, bean:Bean):void
		{
			_setupMetadataTagInvocationCount += 1;
		}
		
		override public function tearDownMetadataTag(metadataTag:IMetadataTag, bean:Bean):void
		{
			_tearDownMetadataTagInvocationCount += 1;
		}
		
		override protected function validateMetadataTag(metadataTag:IMetadataTag):void
		{
			_validateMetadataTagInvocationCount += 1;
		}
		
	}
}