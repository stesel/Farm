package states
{
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
	/**
	 * ...	State Manager
	 * @author Leonid Trofimchuk
	 */
	public class StateManager extends Sprite
	{
		private var resume:Boolean;				//Resume in menu
			
		private var _game:Game;					//Game State
		private var _menu:Menu;					//Menu State 
			
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
				_game.removeEventListener(GameEvent.CALL_MENU, game_callMenu);
				_game.leaveState();
				removeChild(_game);
				_game = null;
			}
		}
			
		private function initGame():void
		{	
			leaveGame();
			_game = new Game();
			addChild(_game);
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
		
	}

}