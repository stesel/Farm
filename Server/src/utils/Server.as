package utils 
{
	import components.InfoText;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.sampler.getSize;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Server extends Sprite 
	{
		private var dataControll:DataControll;			//SQL Base
		
		private var message:String;
		private var messageText:InfoText;
		private var serverSocket: ServerSocket;
		private var clientSockets:Array; 
		private var directionValue:int;
		private var spacingValue:int;
		private var distanceValue:int;
		private var socket:Socket;
		
		public function Server()
		{
			messageText = new InfoText(16, 0x02ff1b);
			messageText.setText("Server: Ready");
			messageText.x = 5;
			messageText.y = 5;
			this.addChild(messageText);
			
			initServer(); 
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods definition
//
//-------------------------------------------------------------------------------------------------	
		
		public function initServer():void 
		{
			if (serverSocket != null)
			{
				serverSocket.close();
			}
			
			clientSockets = new Array();
			
			try
			{
				serverSocket = new ServerSocket();
				serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, connectHandler ); 
				serverSocket.addEventListener(Event.CLOSE, onClose );
				serverSocket.bind(2000, "127.0.0.7" );
				serverSocket.listen(); 
				
				message = "Server: " + String(serverSocket.localPort);
				messageText.setText(message);
			}
			catch(e:SecurityError)
			{
				message = "Server: " +  e.message;
				messageText.setText(message);
			}
			catch (e:Error)
			{
				message = "Server: " +  e.message;
				messageText.setText(message);
			}
			finally 
			{ 
				// init DataBase
				dataControll = new DataControll(); 
			}
			

		}
		
		public function convert(data:Array):ByteArray 
		{
			var result:ByteArray = new ByteArray();
			
			//Pilot Signall
			result.writeByte(0xff);
			result.writeByte(0xff);
			result.writeByte(0xff);
			result.writeByte(0xff);
			result.writeByte(0x55);
			
			//Data
			result.writeByte(data[0]);
			result.writeByte(data[1]);
			result.writeByte(data[2]);
			trace(result);
			return result;
		}
			
		public function deactivate():void
		{
			serverSocket.close();
			serverSocket = null;
			message = null;
			this.removeChild(messageText);
			messageText = null;
			clientSockets.length = 0;
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		//Client Connect Handler
		private function connectHandler(e:ServerSocketConnectEvent):void 
		{
			socket = e.socket as Socket; 
            clientSockets.push(socket); 
             
            socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler); 
            socket.addEventListener(Event.CLOSE, onClientClose); 
            socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError); 
			  
            //Send a connect message 
			message = "Server: " + "Connected to " + socket.localAddress.toString();
			Main.log(message);
			
		}
		
		private function socketDataHandler(e:ProgressEvent):void 
		{
			socket = e.target as Socket;                  
            var socketMessage:String = socket.readUTFBytes(e.bytesLoaded); 
           
			message = "Server: " + "Received: " + socketMessage;
			Main.log(message);
			

			var xml:XML =  new XML(socketMessage);			
			
			
			if (xml.@type == "plant") 
			{
				dataControll.writeVegetableToSQL(xml);
			}
			
			if (xml.@type == "take")
			{
				dataControll.takeVegetable(xml.@name);
			}
				
			if (xml.@type == "step")
			{
				dataControll.makeStep();
			}
						
			if (xml.@type == "get") 
			{	
				dataControll.addEventListener(DataControll.DATA_COMPLETE, onGetAllData);
				dataControll.getAllData();
			}
			
			if (xml.@type == "reset") 
			{
				dataControll.resetData();
			}
			
		}
			
		private function onIOError(e:IOErrorEvent):void 
		{
			message = "Server: " + e.text;
			Main.log(message);
		}
		
		private function onClientClose(e:Event):void 
		{
			socket = null;
			message = "Server: " + "Connection to client closed";
			Main.log(message);
		}
		
		private function onClose(e:Event):void 
		{
			message = "Server: " + "Server socket closed by OS.";
			Main.log(message);
		}
		
		private function onGetAllData(e:Event):void
		{
			dataControll.removeEventListener(DataControll.DATA_COMPLETE, onGetAllData);
			var data:Array = dataControll.allPackage;
			var xml:XML = new XML();
			var xmlChild:XML;
			var tagRoot:String = "response";
			var tagChild:String = "item";
			var tagName:String = "name";
			var tagValue:String = "value";
			var typeName:String = "type";					
			var typeValue1:String = "scores";
			var typeValue2:String = "plant";
			var phaseName:String = "phase";  
			var xName:String = "x";  
			var yName:String = "y";
			var cloverName:String = "clover";
			var potatoName:String = "potato";
			var sunflowerName:String = "sunflower";
			
			xml = <{tagRoot}> </{tagRoot}> ;
			
			for (var i:int = 0; i < data.length; i++) 
			{
				var row:Object = data[i];
				if (row.hasOwnProperty("name"))
				{
					xmlChild = <{tagChild} {typeName}={typeValue2} {tagName}={row.name} {phaseName}={row.phase} {xName}={row.x} {yName}={row.y}/>;							
					xml.appendChild(xmlChild);
				}
				if (row.hasOwnProperty("clover"))
				{
					xmlChild = <{tagChild} {typeName}={typeValue1} {tagName}={cloverName} {tagValue}={row.clover}/>;
					xml.appendChild(xmlChild);			
					xmlChild = <{tagChild} {typeName}={typeValue1} {tagName}={potatoName} {tagValue}={row.potato}/>;
					xml.appendChild(xmlChild);					
					xmlChild = <{tagChild} {typeName}={typeValue1} {tagName}={sunflowerName} {tagValue}={row.sunflower}/>;
					xml.appendChild(xmlChild);
				}
			}
			
			socket.writeUTFBytes(xml.toXMLString()); 
			socket.flush();					
			Main.log("Server sent: " + xml.toXMLString());
		}
	}

}