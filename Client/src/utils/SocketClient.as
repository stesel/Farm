package utils {
		
	/**
	 * ...Class connects to Server Socket
	 * @author Leonid Trofimchuk
	 */
		
	import components.VegetableProperty;
	import events.ModelEvent;
	import flash.utils.ByteArray;
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	
	public class SocketClient extends Socket 
	{
		static public const NOT_RESPOND:String = "notRespond";
		
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
		
		// Read Data from Socket
		private function readResponse(bytes:int):void 
		{
			var data:String;	
			data = readUTFBytes(bytes);
			parseData(data);
		}
		
		//Parse xml-file
		private function parseData(data:String = null):void 
		{
			var xml:XML = new XML(data);
			var xmlList:XMLList = xml.children();
			var obj:Object = { };
			
			if (xmlList.hasOwnProperty("result"))
			{
				obj["clover"] = xmlList.result.@clover;
			}
			
			dispatchEvent(new ModelEvent(ModelEvent.GET_DATABASE, false, false, obj));
			
		}
		
		//Send Request to plant new Vegetable
		public function sendPackage(obj:Object = null):void
		{
			var xml:XML;
			var tag:String = "request";
			var typeName:String = "type";
			var vegetableName:String = "name";
			
			var crop:VegetableProperty = obj["crop"];
			var typeValue:String = obj["tag"]; 
			
			var phaseName:String = "phase";  
			var xName:String = "x";  
			var yName:String = "y";
			
			if (typeValue == "step")
			{
				xml = <{tag} {typeName}={typeValue}/>;
			}
			else if (typeValue == "take")
			{
				var vegetableType1:String = crop.type.toString(); 
				xml = <{tag} {typeName}={typeValue} {vegetableName}={vegetableType1}/>;
			}
			else if (typeValue == "plant")
			{
				var vegetableType2:String = crop.type.toString(); 
				var phaseValue:String = crop.phase.toString(); 
				var xValue:String = crop.x.toString();
				var yValue:String = crop.y.toString();				
				xml = <{tag} {typeName}={typeValue} {vegetableName}={vegetableType2} {phaseName}={phaseValue} {xName}={xValue} {yName}={yValue}/>;
			}
			
			//trace(xml.toXMLString());
			try 
			{
				writeUTFBytes(xml.toXMLString());
				flush();
			}
			catch(e:Error)
			{
				trace(e.message);
				dispatchEvent(new Event(SocketClient.NOT_RESPOND));
			}
		}
			
		private function getDataBase():void 
		{
			var tag:String = "request";
			var typeName:String = "type";
			var typeValue:String = "get";
			var xml:XML = <{tag} {typeName}={typeValue}/>;
			trace(xml.toXMLString());
			try 
			{
				writeUTFBytes(xml.toXMLString());
				flush();
			}
			catch(e:Error)
			{
				trace(e.message);
				dispatchEvent(new Event(SocketClient.NOT_RESPOND));
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
			getDataBase();
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + e);
			dispatchEvent(new Event(SocketClient.NOT_RESPOND));
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