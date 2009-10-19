package org.swizframework.util {
	
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import mx.collections.ListCollectionView;
	import mx.core.Application;
	import mx.events.CollectionEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import org.swizframework.Swiz;
	
	public class BeanLoader extends ListCollectionView {
		private static const logger : ILogger = Log.getLogger( "BeanLoader" );
		
		[Bindable]
		protected var dispatcher : IEventDispatcher = Swiz.systemManager;
		
		public function BeanLoader() {
			super();
			// addEventListener(CollectionEvent.COLLECTION_CHANGE, registerBeans);
		}
		
		/**
		 * Returns a dictionary of the beans contained in this loader. Swiz should
		 * now retrieve beans from loaders itself instead of pushing beans into the factory.
		 *
		 * @return Dictionary
		 */
		public function getBeans() : Dictionary {
			var collItems : Array = ["list", "sort", "filterFunction" ];
			var xmlDescription : XML = describeType( this );
			var accessors : XMLList = xmlDescription.accessor.( @access == "readwrite" ).@name;
			
			var beans : Dictionary = new Dictionary();
			var name : String;
			
			for ( var i : uint = 0; i<accessors.length(); i++ ) {
				name = accessors[ i ];
				if ( collItems.indexOf( name ) < 0 ) {
					beans[ name ] = this[ name ];
				}
			}
			return beans;
		}
		
		/**
		 * Deprecated
		 */
		public function registerBeans( e : CollectionEvent ) : Array {
			if ( Swiz.hasLogLevel( LogEventLevel.INFO ) )
				logger.info( "load up these beans!" );
			
			var swiz : Swiz = Swiz.getInstance();
			var collItems : Array = ["list", "sort", "filterFunction" ];
			var xmlDescription : XML = describeType( this );
			var accessors : XMLList = xmlDescription.accessor.( @access == "readwrite" ).@name;
			
			var beans : Array;
			var name : String;
			for ( var i : uint = 0; i<accessors.length(); i++ ) {
				name = accessors[ i ];
				if ( collItems.indexOf( name ) < 0 ) {
					// trace( "trying to add: "+name );
					// if (this[ name] is SwizBean || this[ name] is AbstractService)
					swiz.addBean( name, this[ name ] );
					beans.push( name );
				}
			}
			
			return beans;
		}
	
	}
}