package org.swizframework.util {
	import mx.messaging.Channel;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	
	import org.swizframework.Swiz;
	import org.swizframework.factory.IInitializingBean;
	
	public class DynamicChannelSet extends ChannelSet implements IInitializingBean {
		// Flash remoting config issues       
		private static const DEFAULT_CHANNEL_ID : String = "orca-amf";
		private static const DEFAULT_SERVER_NAME : String = "localhost";
		private static const DEFAULT_SERVER_PORT : int = 8080;
		private static const DEFAULT_CONTEXT_ROOT : String = "/";
		private static const DEFAULT_ENDPOINT_NAME : String = "messagebroker/amf";
		
		public var channelId : String;
		public var serverName : String;
		public var serverPort : int;
		public var contextRoot : String;
		public var endPointName : String;
		
		private var channelCreated : Boolean = false;
		
		public function DynamicChannelSet( channelIds : Array = null, clusteredWithURLLoadBalancing : Boolean = false ) {
			super( channelIds, clusteredWithURLLoadBalancing );
		}
		
		public function initialize() : void {
			if ( !channelCreated ) {
				// create a new AMF Channel with our configuration
				var amfChannel:Channel = new AMFChannel( CHANNEL_ID, AMF_ENDPOINT );
				addChannel( amfChannel );
				channelCreated = true;
			}
		}
		
		/**
		 * Creates a proper AMF Endpoint with configured parameters. Location depends on how
		 * the application is accessed (http:// or file://)
		 **/
		private function get AMF_ENDPOINT() : String {
			var app:* = Swiz.application;
			if ( app.url != null && app.url.indexOf( "http:" ) != -1 ) {
				return "http://{server.name}:{server.port}" + CONTEXT_ROOT +"/" + ENDPOINT_NAME; // /messagebroker/amf";
			} else {
				return "http://" + SERVER_NAME + ":" + SERVER_PORT + CONTEXT_ROOT +"/" + ENDPOINT_NAME; // /messagebroker/amf";
			}
		}
		
		/**
		 * returns either default or configured channel id
		 **/
		private function get CHANNEL_ID() : String {
			return channelId != null ? channelId : DEFAULT_CHANNEL_ID;
		}
		
		/**
		 * returns either default or configured server name
		 **/
		private function get SERVER_NAME() : String {
			return serverName != null ? serverName : DEFAULT_SERVER_NAME;
		}
		
		/**
		 * returns either default or configured server port
		 **/
		private function get SERVER_PORT() : int {
			return serverPort != 0 ? serverPort : DEFAULT_SERVER_PORT;
		}
		
		/**
		 * returns either default or configured context root
		 **/
		private function get CONTEXT_ROOT() : String {
			return contextRoot != null ? contextRoot : DEFAULT_CONTEXT_ROOT;
		}
		
		private function get ENDPOINT_NAME() : String {
			return endPointName != null ? endPointName : DEFAULT_ENDPOINT_NAME;
		}
	
	}
}