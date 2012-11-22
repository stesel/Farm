package game 
{
	import components.VegetableProperty;
	import events.GameEvent;
	import events.ModelEvent;
	import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.sampler.NewObjectSample;
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
		
		//Send to server Planed Vegetable
		public function sendRequest(crop:VegetableProperty):void 
		{
			var obj:Object = { };
			obj["tag"] = "plant";
			obj["crop"] = crop;
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
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
			var crop:VegetableProperty = new VegetableProperty("clover");
			var obj:Object = { };
			obj["tag"] = "take";
			obj["crop"] = crop;
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
			
		}
		
		private function onTakePotato():void 
		{
			_model.gatherPotato();
			var crop:VegetableProperty = new VegetableProperty("potato");
			var obj:Object = { };
			obj["tag"] = "take";
			obj["crop"] = crop;
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
		}
		
		private function onTakeSunFlower():void 
		{
			_model.gatherSunFlower();
			var crop:VegetableProperty = new VegetableProperty("sunflower");
			var obj:Object = { };
			obj["tag"] = "take";
			obj["crop"] = crop;
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
		}
		
		private function onMakeMove():void 
		{
			_model.move();
			var obj:Object = { };
			obj["tag"] = "step";
			dispatchEvent(new ModelEvent(ModelEvent.SEND_REQUEST, false, false, obj));
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