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
		
		private var window:NativeWindow;
		
		
		private var startButton:SimpleButton;
		private var directionTitlte:InfoText;
		private var distanceTitlte:InfoText;
		private var spacingTitlte:InfoText;
		private var direction:InfoText;
		private var distance:InfoText;
		private var spacing:InfoText;
		
		private var directionValue:int = 0;
		private var distanceValue:int = 0;
		private var spacingValue:int = 0;
		
		private var server:Server;
		private var dataControll:DataControll;
		
		public function Main() 
		{
			if (stage) 
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
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
			
			startButton = new SimpleButton("Start Server");
			startButton.x = stage.stageWidth / 2;
			startButton.y = stage.stageHeight / 2;
			this.addChild(startButton);
			startButton.addEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed1);
			
		}
		
		private function startButton_buttonPressed1(e:ButtonEvent):void 
		{
			directionTitlte = new InfoText();
			directionTitlte.setText("Direction: ");
			directionTitlte.x = 300;
			directionTitlte.y = 225;
			this.addChild(directionTitlte);
			spacingTitlte = new InfoText();
			spacingTitlte.setText("Spacing: ");
			spacingTitlte.x = 300;
			spacingTitlte.y = 275;
			this.addChild(spacingTitlte);
			distanceTitlte = new InfoText();
			distanceTitlte.setText("Distance: ");
			distanceTitlte.x = 300;
			distanceTitlte.y = 325;
			this.addChild(distanceTitlte);
			
			direction = new InfoText(18, 0xe54500);
			direction.setText("Empty");
			direction.selectable = true;
			direction.type = TextFieldType.INPUT;
			direction.restrict = "0-1";
			direction.maxChars = 1;
			direction.border = true;
			direction.x = 400;
			direction.y = 225;
			direction.background = true;
			direction.backgroundColor = 0xd0d0d0;
			this.addChild(direction);
			direction.addEventListener(Event.CHANGE, onTextChange);
			
			spacing = new InfoText(18, 0xe54500);
			spacing.setText("Empty");
			spacing.selectable = true;
			spacing.type = TextFieldType.INPUT;
			spacing.restrict = "0-9";
			spacing.maxChars = 3;
			spacing.border = true;
			spacing.x = 400;
			spacing.y = 275;
			spacing.background = true;
			spacing.backgroundColor = 0xd0d0d0;
			this.addChild(spacing);
			spacing.addEventListener(Event.CHANGE, onTextChange);
			
			distance = new InfoText(18, 0xe54500);
			distance.setText("Empty");
			distance.selectable = true;
			distance.type = TextFieldType.INPUT;
			distance.restrict = "0-9";
			distance.maxChars = 3;
			distance.border = true;
			distance.x = 400;
			distance.y = 325;
			distance.background = true;
			distance.backgroundColor = 0xd0d0d0;
			this.addChild(distance);
			distance.addEventListener(Event.CHANGE, onTextChange);
			
			startButton.removeEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed1);
			this.removeChild(startButton);
			startButton = null;
			
			server = new Server();
			this.addChild(server);
			
			dataControll = new DataControll();
			
			startButton = new SimpleButton("Restart Server");
			startButton.x = stage.stageWidth - startButton.width / 2 - 10;
			startButton.y = stage.stageHeight - startButton.height / 2 - 10;
			this.addChild(startButton);
			startButton.addEventListener(ButtonEvent.BUTTON_PRESSED, startButton_buttonPressed2);
		}
		
		private function onTextChange(e:Event):void 
		{
			var sp:int = int(spacing.text);
			var ds:int = int(distance.text);
			var dr:int = int(direction.text);
			if(sp >= 0 && sp <= 100)
				spacingValue = sp;
			if(ds >= 0 && ds <= 100)
				distanceValue = ds;
			if(dr >= 0 && dr <= 1)
				directionValue = dr;
				
			if (server == null)
				return;
			server.setValues(directionValue, spacingValue, distanceValue);
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