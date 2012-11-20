package 
{
	import components.ButtonEvent;
	import components.InfoText;
	import components.SimpleButton;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.text.TextFieldType;
	import utils.DataControll;
	import utils.Server;
	
	[SWF(backgroundColor = "#008080", frameRate = "30", width = "800", height = "600")]
	/**
	 * ...Server App
	 * @author Leonid Trofimchuk
	 */
	public class Main extends Sprite 
	{
		private var window:NativeWindow;				//Window
		private var startButton:SimpleButton;			//Start/Restart Button
		private var statusText:InfoText;				//Current State
			
		private var server:Server;						//Server Socket
		private var dataControll:DataControll;			//SQL Base
		
		public function Main() 
		{
			if (stage) 
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function init(e:Event):void 
		{
			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
				
			//Window Settings	
			window = stage.nativeWindow;
			window.width = window.stage.stageWidth;	
			window.height = window.stage.stageHeight;									
			window.x = 0;
			window.y = 0;
			
			if (!window.active)	
			{	
				//Title
				window.title = "Farm Server";										
				window.activate();
				
				window.addEventListener(Event.CLOSE, windowCloseHandler);
			}	
			
			statusText = new InfoText(16);
			statusText.setText("Ready");
			statusText.x = 5;
			statusText.y = stage.stageHeight - statusText.height - 5;
			addChild(statusText);
			
			startButton = new SimpleButton("Start Server");
			startButton.x = stage.stageWidth / 2;
			startButton.y = stage.stageHeight / 2;
			this.addChild(startButton);
			startButton.addEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed1);
			
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------		
		
		private function startButton_buttonPressed1(e:ButtonEvent):void 
		{
			startButton.removeEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed1);
			this.removeChild(startButton);
			startButton = null;
			//init Server
			server = new Server();
			this.addChild(server);
			
			//init DataBase
			dataControll = new DataControll();
			
			startButton = new SimpleButton("Restart Server");
			startButton.x = stage.stageWidth / 2;
			startButton.y = stage.stageHeight / 2;
			this.addChild(startButton);
			startButton.addEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed2);
		}
		
		private function startButton_buttonPressed2(e:ButtonEvent):void 
		{
			server.initServer();
		}
		
		private function windowCloseHandler(e:Event):void 
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}