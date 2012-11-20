package game 
{
	import events.GameEvent;
	import events.ModelEvent;
    import flash.events.EventDispatcher;
	 /**
     * ...Model component of MVC
     * @author Leonid Trofimchuk
     */
    public class Model extends EventDispatcher 
	{
		private var _result: Object;					//Game Scores
		
		public function Model() 
		{
            init();
        }
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		
		private function init():void 
		{
			if (_result == null)
			{
				_result = { };
				_result["clover"] = 0;
				_result["potato"] = 0;
				_result["sunflover"] = 0;
			}
		}
		
		//New Clover
		public function getClover():void 
		{
			var obj:Object = { };
			obj["newVegatable"] = "../bin/res/clover/1.png";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//New Potato
		public function getPotato():void 
		{
			var obj:Object = { };
			obj["newVegatable"] = "../bin/res/potato/1.png";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//New Sunflower
		public function getSunFlower():void 
		{
			var obj:Object = { };
			obj["newVegatable"] = "../bin/res/sunflower/1.png";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//To Do Moving
		public function move():void 
		{
			var obj:Object = { };
			obj["move"] = true;
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//Gather Clover
		public function gatherClover():void 
		{
			var obj:Object = { };
			obj["takeVegetables"] = "clover";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//Gather Potato
		public function gatherPotato():void 
		{
			var obj:Object = { };
			obj["takeVegetables"] = "potato";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
		//Gather Sunflower
		public function gatherSunFlower():void 
		{
			var obj:Object = { };
			obj["takeVegetables"] = "sunflower";
			dispatchEvent(new ModelEvent(ModelEvent.ACTION_PROCESSED, false, false, obj));
		}
		
//--------------------------------------------------------------------------
//
//  Getters
//
//--------------------------------------------------------------------------
		
		public function get result():Object
		{
			return _result;
		}
		
		public function set result(value:Object):void
		{
			_result = value;
		}
    }

}