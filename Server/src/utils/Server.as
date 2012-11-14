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
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Server extends Sprite 
	{
		private var message:String;
		private var messageText:InfoText;
		private var serverSocket: ServerSocket;
		private var clientSockets:Array; 
		private var directionValue:int;
		private var spacingValue:int;
		private var distanceValue:int;
		
		public function Server()
		{
			messageText = new InfoText(16, 0x02ff1b);
			messageText.setText("Server: Ready");
			messageText.x = 10;
			messageText.y = 10;
			this.addChild(messageText);
			
			initServer(); 
		}
		
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
				serverSocket.bind( 2000, "127.0.0.7" );
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
		}
		
		private function connectHandler(e:ServerSocketConnectEvent):void 
		{
			var socket:Socket = e.socket as Socket; 
            clientSockets.push(socket); 
             
            socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler); 
            socket.addEventListener(Event.CLOSE, onClientClose); 
            socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError); 
			  
            //Send a connect message 
            socket.writeUTFBytes("Connected."); 
            socket.flush();
			message = "Server: " + "Connected.";
			messageText.setText(message);
		}
		
		private function socketDataHandler(e:ProgressEvent):void 
		{
			var socket:Socket = e.target as Socket 
                 
            var socketMessage:String = socket.readUTFBytes(socket.bytesAvailable); 
           
			message = "Server: " + "Received: " + socketMessage;
			messageText.setText(message);
			
			var data:Array = new Array(directionValue, spacingValue, distanceValue); 
			
            socket.writeBytes(convert(data)); 
            socket.flush(); 
			message = "Server: " +  "Sending: " + data;
			messageText.setText(message);
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
			
		private function onIOError(e:IOErrorEvent):void 
		{
			message = "Server: " + e.text;
			messageText.setText(message);
		}
				
		private function onClientClose(e:Event):void 
		{
			message = "Server: " + "Connection to client closed";
			messageText.setText(message);
		}
		
		private function onClose(e:Event):void 
		{
			message = "Server: " + "Server socket closed by OS.";
			messageText.setText(message);
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
		
		public function setValues(dir:int = 0, s:int = 0, d:int = 0):void
		{
			directionValue = dir;
			spacingValue = s;
			distanceValue = d;
			
			var data:String = " ";
			if (clientSockets.length != 0)
			{
				var socket: Socket = clientSockets[clientSockets.length - 1];
				socket.writeBytes(convert([directionValue, spacingValue, distanceValue]));
				socket.flush(); 
			}
			
			 
			
		}
	}

}