package org.swizframework.utils.commands
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	import org.swizframework.core.Prototype;
	import org.swizframework.reflection.TypeCache;
	
	/**
	 * Class used to map events to the commands they should trigger.
	 */
	public class CommandMap implements ISwizAware
	{
		// ========================================
		// protected properties
		// ========================================
		
		/**
		 * Backing variable for swiz setter.
		 */
		protected var _swiz:ISwiz;
		
		/**
		 * Dictionary to hold mappings.
		 */
		protected var map:Dictionary = new Dictionary();
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Setter to satisfy ISwizAware interface contract.
		 * 
		 * @see org.swizframework.core.ISwizAware
		 */
		public function set swiz( swiz:ISwiz ):void
		{
			_swiz = swiz;
			
			mapCommands();
		}
		
		// ========================================
		// protected methods
		// ========================================
		
		/**
		 * Handler method triggered when a mapped event is caught.
		 */
		protected function handleCommandEvent( event:Event ):void
		{
			// make sure we have a mapping
			if( map[ event.type ] != null )
			{
				// retrieve mapping
				var commandMapping:CommandMapping = CommandMapping( map[ event.type ] );
				
				// validate event class
				if( !( event is commandMapping.eventClass ) )
					return;
				
				// get our command bean
				var commandPrototype:Bean = _swiz.beanFactory.getBeanByType( commandMapping.commandClass );
				
				if( commandPrototype == null )
					throw new Error( "Command bean not found for mapped event type." );
				
				if( commandPrototype is Prototype )
				{
					// get a new instance of the command class
					var command:Object = Prototype( commandPrototype ).source;
					
					if( !( command is ICommand ) )
						throw new Error( "Commands must implement org.swizframework.utils.commands.ICommand." );
					
					// provide event reference if command is IEventAwareCommand
					if( command is IEventAwareCommand )
						IEventAwareCommand( command ).event = event;
					
					ICommand( command ).execute();
				}
				else
				{
					throw new Error( "Commands must be provided as Prototype beans." );
				}
				
				if( commandMapping.oneTime )
					delete map[ commandMapping.eventType ];
			}
		}
		
		/**
		 * Abstract method that sub classes should override and populate with calls to <code>mapCommand()</code>.
		 * Mapping commands here (and letting it be called for you) ensures all the necessary pieces have
		 * been provided before attempting to create any mappings.
		 */
		protected function mapCommands():void
		{
			// do nothing, subclasses must override
		}
		
		/**
		 * Method that performs actual event to command mapping.
		 */
		protected function mapCommand( eventType:String, commandClass:Class, eventClass:Class = null, oneTime:Boolean = false ):void
		{
			if( map[ eventType ] != null )
				throw new Error( "Duplicate mappings are not allowed." );
			
			// store mapping in dictionary
			map[ eventType ] = new CommandMapping( eventType, commandClass, eventClass, oneTime );
			
			// this should always evaluate to true, but checking for prior mapping just in case
			if( _swiz.beanFactory.getBeanByType( commandClass ) == null )
			{
				// create a Prototype for adding to the BeanFactory
				var commandPrototype:Prototype = new Prototype( commandClass );
				commandPrototype.typeDescriptor = TypeCache.getTypeDescriptor( commandClass, _swiz.domain );
				// add command bean for later instantiation
				_swiz.beanFactory.addBean( commandPrototype );
			}
			
			// listen for event that will trigger this command
			_swiz.dispatcher.addEventListener( eventType, handleCommandEvent, false, 0, true );
		}
	}
}
import flash.events.Event;

/**
 * Inner class used to hold the details of a mapping.
 */
class CommandMapping
{
	public var eventType:String;
	public var commandClass:Class;
	public var eventClass:Class;
	public var oneTime:Boolean;
	
	public function CommandMapping( eventType:String, commandClass:Class, eventClass:Class = null, oneTime:Boolean = false )
	{
		this.eventType = eventType;
		this.commandClass = commandClass;
		this.eventClass = eventClass || Event;
		this.oneTime = oneTime;
	}
}