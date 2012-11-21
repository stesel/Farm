package game 
{
	import components.VegetableProperty;
	import events.GameEvent;
	import events.ModelEvent;
	import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
	import flash.display.Sprite;
    /**
	 * ...Controller component of MVC
	 * @author Leonid Trofimchuk
	 */
	public class Controller extends EventDispatcher 
	{
		private var _model:Model;
		private var buttonActions:Object;
		
		public function Controller(model:Model = null) 
		{
			this._model = model;
			initButtonActions();
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
			
		//On Leaving Game
		public function stopGame():void 
		{
			this._model = null;
		}
		
		//Sort Action Function Object
		public function onAction(action: String = null):void
		{
			var method:Function = buttonActions[action];
			if (method != null) method.call(this);
		}
		
		//Bind Actions
		private function initButtonActions():void 
		{
			buttonActions = { };
			
			buttonActions[GameActions.PLANT_CLOVER] = onPlantClover;
			buttonActions[GameActions.PLANT_POTATO] = onPlantPotato;
			buttonActions[GameActions.PLANT_SUN_FLOWER] = onPlantSunFlower;
			
			buttonActions[GameActions.TAKE_CLOVER] = onTakeClover;
			buttonActions[GameActions.TAKE_POTATO] = onTakePotato;
			buttonActions[GameActions.TAKE_SUN_FLOWER] = onTakeSunFlower;
			
			buttonActions[GameActions.MAKE_MOVE] = onMakeMove;
			
			buttonActions[GameActions.MENU] = onCallMenu;
		}
		
		
		public function sendRequest(properties:VegetableProperty):void 
		{
			var obj:Object = { };
			obj["request"] = properties;
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
			_model.sendRequest(properties);
		}
		
		private function onPlantClover():void 
		{
			_model.getClover();
		}
		
		private function onPlantPotato():void 
		{
			_model.getPotato();
		}
		
		private function onPlantSunFlower():void 
		{
			_model.getSunFlower();
		}
		
		private function onTakeClover():void 
		{
			_model.gatherClover();
		}
		
		private function onTakePotato():void 
		{
			_model.gatherPotato();
		}
		
		private function onTakeSunFlower():void 
		{
			_model.gatherSunFlower();
		}
		
		private function onMakeMove():void 
		{
			_model.move();
		}
		
		private function onCallMenu():void 
		{
			dispatchEvent(new GameEvent(GameEvent.CALL_MENU));
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Event handlers
//
//-------------------------------------------------------------------------------------------------
		
		
    }
 
}