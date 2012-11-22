package states
{
	import components.Messages;
	import components.VegetableProperty;
	import events.GameEvent;
	import events.ModelEvent;
	import events.StateEvent;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.system.fscommand;
	import flash.utils.setTimeout;
	import utils.SocketClient;
	/**
	 * ...	State Manager
	 * @author Leonid Trofimchuk
	 */
	public class StateManager extends Sprite
	{
		private var socketClient:SocketClient	//Socket
		private var resume:Boolean = false;		//Resume in menu
			
		private var _game:Game;					//Game State
		private var _menu:Menu;					//Menu State
		private var result:Object;				//Game result
			
		public function StateManager() 
		{
			if (stage)
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			socketClient = new SocketClient("127.0.0.7", 2000);
			socketClient.enable();
			socketClient.addEventListener(ModelEvent.GET_DATABASE, socketClient_getDatabase);
			socketClient.addEventListener(SocketClient.NOT_RESPOND, socketClient_notRespond);
			
			
			
			///////////
			var vector:Vector.<VegetableProperty> = new Vector.<VegetableProperty>;
			vector.length = 5;
			for (var i:int = 0;i < vector.length; i++)
			{
				var item: VegetableProperty = new VegetableProperty("sunflower", 5, 100 * (i+2), 100 * (i+2));
				vector[i] = item;
			}
			var obj:Object = { };
			obj["vegetablesOnPlant"] = vector;
			obj["clover"] = 3;
			obj["potato"] = 4;
			obj["sunflower"] = 5;
			result = obj;
			resume = true;
			/////////
			initMenu();
		}
			
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------	
			
		private function initMenu():void 
		{
			_menu = new Menu(resume);
			_menu.addEventListener(StateEvent.STATE_CHANGED, menu_stateChanged);
			addChild(_menu);
		}
			
		private function removeMenu():void
		{
			_menu.removeEventListener(StateEvent.STATE_CHANGED, menu_stateChanged);
			removeChild(_menu);
			_menu = null;
		}
			
		private function leaveGame():void
		{
			if (_game != null)
			{
				_game.removeEventListener(ModelEvent.SEND_REQUEST, game_sendRequest);
				_game.removeEventListener(GameEvent.CALL_MENU, game_callMenu);
				_game.leaveState();
				removeChild(_game);
				_game = null;
			}
		}
			
		private function initGame():void
		{	
			leaveGame();
			_game = new Game(result);
			addChild(_game);
			_game.addEventListener(ModelEvent.SEND_REQUEST, game_sendRequest);
			_game.addEventListener(GameEvent.CALL_MENU, game_callMenu);
		}
		
		private function closeApp():void 
		{
			fscommand("quit");
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers Definition
//
//-------------------------------------------------------------------------------------------------	
		
		private function socketClient_getDatabase(e:ModelEvent):void 
		{
			
			if (e.result["clover"] >= 0)
			{
				result = e.result;
				resume = true;
			}
			initMenu();
		}
		
		private function game_callMenu(e:GameEvent):void 
		{
			if (_menu != null)
				return;
			_game.deactivateGame();
			resume = true;
			initMenu();
		}
			
		private function menu_stateChanged(e:StateEvent):void 
		{
			switch (e.onState)
			{
				case "RESUME":
					if(_game != null)
						_game.activateGame();
					else
						initGame();
					removeMenu();
					break;
				case "NEW GAME":
					result = null;
					socketClient.resetDataBase();
					initGame();
					removeMenu();
					break;
				case "EXIT":
					closeApp();
					break;
				default:
					closeApp();
			}
		}
			
		private function game_sendRequest(e:ModelEvent):void 
		{
			socketClient.sendPackage(e.result);
		}
		
		private function socketClient_notRespond(e:Event):void 
		{
			var message:Messages = new Messages("Server Does Not Respond", 0xff3300);
			addChild(message);
			message.addEventListener(Messages.REMOVE_MESSAGE, message_removeMessage);
		}
		
		private function message_removeMessage(e:Event):void 
		{
			var message:Messages = e.target as Messages;
			message.removeEventListener(Messages.REMOVE_MESSAGE, message_removeMessage);
			removeChild(message);
		}
		
	}

}