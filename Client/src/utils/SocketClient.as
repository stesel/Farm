package utils {
		
	/**
	 * ...Class connects to Server Socket
	 * @author Leonid Trofimchuk
	 */
		
	import components.VegetableProperty;
	import flash.utils.ByteArray;
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	
	public class SocketClient extends Socket 
	{
		
		public function SocketClient(host:String = null, port:uint = 0) 
		{
			super();
			if (host && port) 
			{
				super.connect(host, port);
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods definition
//
//-------------------------------------------------------------------------------------------------	
		
		public function enable():void 
		{
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		public function removeListeners():void 
		{
			removeEventListener(Event.CLOSE, closeHandler);
			removeEventListener(Event.CONNECT, connectHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		//Send to Socket
		private function sendRequest(data:String):void 
		{
			writeUTFBytes(data);
			flush();
		}
		
		// Read Data from Socket
		private function readResponse(bytes:int):void 
		{
			var data:String;	
			data = readUTFBytes(bytes);
			parseData(data);
		}
		
		private function parseData(data:String = null):void 
		{
			trace(data);
		}
		
		//Send Request to plant new Vegetable
		public function sendPackage(crop:VegetableProperty = null):void
		{
			var tagname:String = "plant";  
			var typeName:String = "type";  
			var typeValue:String = crop.type.toString();  
			var phaseName:String = "phase";  
			var phaseValue:String = crop.phase.toString();  
			var xName:String = "x";  
			var xValue:String = crop.x.toString(); 
			var yName:String = "y";
			var yValue:String = crop.y.toString();
			
			var xml:XML = <{tagname}{typeName}={typeValue} {phaseName}={phaseValue} {xName}={xValue} {yName}={yValue}> </{tagname}>;
			trace(xml.toXMLString());
			try 
			{
				writeUTFBytes(xml.toXMLString());
				flush();
			}
			catch(e:Error)
			{
				trace(e.message);
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		private function closeHandler(e:Event):void 
		{
			trace("closeHandler: " + e);
		}
		
		private function connectHandler(e:Event):void 
		{
			trace("connectHandler: " + e);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + e);
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + e);
		}
		
		private function socketDataHandler(e:ProgressEvent):void
		{
			readResponse(e.bytesLoaded);
		}
	}
}