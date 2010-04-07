package org.swizframework.processors
{
	import flash.events.IEventDispatcher;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	
	/**
	 * Dispatcher Processor
	 */
	public class DispatcherProcessor extends BaseMetadataProcessor
	{
		// ========================================
		// protected static constants
		// ========================================
		
		protected static const DISPATCHER:String = "Dispatcher";
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 *
		 */
		override public function get priority():int
		{
			return ProcessorPriority.DISPATCHER;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		/**
		 * Constructor
		 */
		public function DispatcherProcessor( metadataNames:Array = null )
		{
			super( ( metadataNames == null ) ? [ DISPATCHER ] : metadataNames );
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 * @inheritDoc
		 */
		override public function setUpMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			var scope:String;
			
			if( metadataTag.hasArg( "scope" ) )
				scope = metadataTag.getArg( "scope" ).value;
			else if( metadataTag.args.length > 0 && MetadataArg(metadataTag.args[0]).key == "" )
				scope = MetadataArg(metadataTag.args[0]).value;
			
			var dispatcher:IEventDispatcher = null;
			
			// if the mediate tag defines a scope, set proper dispatcher, else use defaults
			if( scope == SwizConfig.GLOBAL_DISPATCHER )
				dispatcher = swiz.globalDispatcher;
			else if( scope == SwizConfig.LOCAL_DISPATCHER )
				dispatcher = swiz.dispatcher;
			else
				dispatcher = swiz.config.defaultDispatcher == SwizConfig.LOCAL_DISPATCHER ? swiz.dispatcher : swiz.globalDispatcher;
			
			bean.source[ metadataTag.host.name ] = dispatcher;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function tearDownMetadataTag( metadataTag:IMetadataTag, bean:Bean ):void
		{
			bean.source[ metadataTag.host.name ] = null;
		}
	}
}