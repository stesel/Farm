package states
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import components.InfoText;
	import components.SimpleButton;
	import events.ButtonEvent;
	import events.StateEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.BlurFilter;
	import flash.filters.GradientGlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...This class creates Menu
	 * @author Leonid Trofumchuk
	 */
	public class Menu extends Sprite implements IState
	{
		static public const NEW_GAME:String = "NEW GAME";			//Action New Game Const 
		static public const RESUME:String = "RESUME";				//Action Resume Const 
		static public const EXIT:String = "EXIT";					//Action Exit Const 
		static public const SOUND_SWITCH:String = "soundSwitch"; 	//Sound Switch Const
		
		private var resumeFlag:Boolean;								//Resume Game Availability
		private var newFlag:Boolean =true;							//New Game Availability
		private var exitFlag:Boolean =true;							//Exit Game Availability
		
		private var numOfBut:int;									//Number of Buttons in Menu
			
		private var buttonActions:Object = {};						//Menu Actions
		
		private var initButtonPos:int = 150;						//Initial Button Position
		private var initButHeight:int = 50;							//Initial Button Height
		private var yOffSet:int = 100;								//Button Y OffSet
		private var hMultiply:int = 60;								//Height Multiply
		private var nextX:int;										//Finite Button X value
		
		private var buttonArray:Vector.<SimpleButton>;				//Main container
		private var header:InfoText;								//Header
		
		/**
		 * Constructor
		 * @param	sFlag		Sound Button Flag
		 * @param	rFlag		Resume Game Availability
		 */
		public function Menu(rFlag:Boolean = false) 
		{
			resumeFlag = rFlag;
			
			if (stage)
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			enterState();
		}

//-------------------------------------------------------------------------------------------------
//
//  Interface  Methods definition
//
//-------------------------------------------------------------------------------------------------	
		
		public function enterState():void
		{
			
			//Header
			header = new InfoText(80, 0xffba16, true);
			header.setText("Farm");
			header.x = (stage.stageWidth - header.width) / 2;
			header.y = header.height * 1.7;
			addChild(header);
			
			initActions();
			initMenu();
		}
		
		public function leaveState():void
		{
			numOfBut = 0;
			for (var i:int = 0; i < buttonArray.length; i++)
			{	
				var button:SimpleButton = buttonArray[i];
				button.removeEventListener(ButtonEvent.BUTTON_PRESSED, buttonPressed);
				button.disable();
				removeChild(button);
				button = null;
			}
			buttonArray.length = 0;
			removeChild(header);
			header = null;
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods definition
//
//-------------------------------------------------------------------------------------------------
		/**
		 * Actions Initialization
		 */
		private function initActions():void 
		{
			buttonActions[RESUME] = onResume;
			buttonActions[NEW_GAME] = onNewGame;
			buttonActions[EXIT] = onExit;
		}
		
		/**
		 * Menu Initialization
		 */
		private function initMenu():void
		{
			buttonArray = new Vector.<SimpleButton>();
			//Check Flags And Create Buttons
			if (resumeFlag)
			{
				createButton("RESUME");
			}
			if (newFlag)
			{
				createButton("NEW GAME");
			}
			if (exitFlag)
			{
				createButton("EXIT");
			}
		}
		
		/**
		 * @param	st	Button Name
		 * Create Button
		 */
		private function createButton(st:String):void 
		{
			var button: SimpleButton = new SimpleButton(st);
			button.scaleY = 0.001;
			button.x = - 150;
			button.y = stage.stageHeight/2 + numOfBut * hMultiply + initButHeight; 
			addChild(button);
			nextX = stage.stageWidth / 2;
			TweenLite.to(button, 0.5, { x:nextX, y: button.y, scaleY:1, ease:Back.easeOut } );
			numOfBut++;
			button.enable();
			button.addEventListener(ButtonEvent.BUTTON_PRESSED, buttonPressed);
			buttonArray.push(button);
		}
			
		private function onNewGame(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.NEW_GAME));
			leaveState();
			resumeFlag = true;
		}
		
		private function onResume(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.RESUME));
			leaveState();
		}
		
		public function onExit(): void
		{
			dispatchEvent(new StateEvent(StateEvent.STATE_CHANGED, false, false, Menu.EXIT));
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------	
		
		private function buttonPressed(e:ButtonEvent):void 
		{
			var method:Function = buttonActions[e.label];
			if (method != null) method.call(this);
		}
		
	}

}