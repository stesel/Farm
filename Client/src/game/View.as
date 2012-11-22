package game 
{
	import components.ContentLoader;
	import components.InfoText;
	import components.ResourseLoader;
	import components.SimpleButton;
	import components.VegetableProperty;
	import events.ButtonEvent;
	import events.GameEvent;
	import events.ModelEvent;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
    /**
	 * ... View component of MVC
	 * @author Leonid Trofimchuk
	 */
	public class View extends Sprite 
	{
		private var _model:Model;           						// Model
		private var _controller:Controller;         				// Controller
		
		private var playerScore:InfoText;							//Player points
		private var cpuScore:InfoText;								//cpu points
		
		private var plant:Sprite;									//Main Sprite
		private var resourses:Vector.<ResourseLoader>;				//External Resourses
		private var buttonArray:Vector.<SimpleButton>;				//Button Array
		
		private var mouseX0:Number;									//Mouse Dragging
		private var mouseY0:Number;									//Mouse Dragging
		
		private var _vegetables:Vector.<ResourseLoader>;			//Vegetables Array
		private var vegIndex:Vector.<int>;							//Vegetables Index Array
		
		private var _harvest:Object = { };							//Harvest
		
		private var cloverText:InfoText;							//Clover gathered Text
		private var potatoText:InfoText;							//Potato gathered Text
		private var sunflowerText:InfoText;							//Sunflower gathered Text
		
        public function View(model:Model, controller:Controller)
		{
			this._model = model;									// Reference to the model
			this._controller = controller;							// Reference to the model
			
			if (stage)
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init)
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			initPlant();
			initVegetables();
			initButtonList();
			initListeners();
			initHarvestResults();
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Methods
//
//-------------------------------------------------------------------------------------------------
		
		private function initPlant():void 
		{
			plant = new Sprite();
			addChild(plant);
			var ground: ContentLoader = new ContentLoader("../bin/res/bg.jpg");
			ground.addEventListener(Event.COMPLETE, groundLoadComplete);
		}
		
		private function initVegetables():void 
		{
			_vegetables = new Vector.<ResourseLoader>;
			resourses = new Vector.<ResourseLoader>;
			vegIndex = new Vector.<int>;
		}
			
		//Create Buttons
		private function initButtonList():void 
		{
			buttonArray = new Vector.<SimpleButton>;
			
			var plantClover:SimpleButton = new SimpleButton("Plant Clover", 20);
			plantClover.x =  plantClover.width / 2 + 4;
			plantClover.y =  stage.stageHeight - 3 * (plantClover.height + 5) + plantClover.height / 2;
			addChild(plantClover);
			
			var plantPotato:SimpleButton = new SimpleButton("Plant Potato", 20);
			plantPotato.x =  plantPotato.width / 2 + 4;
			plantPotato.y =  stage.stageHeight - 2 * (plantPotato.height + 5) + plantPotato.height / 2;
			addChild(plantPotato);
			
			var plantSunFlower:SimpleButton = new SimpleButton("Plant Sun Flower", 20);
			plantSunFlower.x =  plantSunFlower.width / 2 + 4;
			plantSunFlower.y =  stage.stageHeight - plantSunFlower.height / 2 - 5;
			addChild(plantSunFlower);
			
			
			var takeClover:SimpleButton = new SimpleButton("Take Clover", 20);
			takeClover.x =  stage.stageWidth - takeClover.width / 2 - 4;
			takeClover.y =  stage.stageHeight - 3 * (takeClover.height + 5) + takeClover.height / 2;
			addChild(takeClover);
			
			var takePotato:SimpleButton = new SimpleButton("Take Potato", 20);
			takePotato.x =  stage.stageWidth - plantPotato.width / 2 - 4;
			takePotato.y =  stage.stageHeight - 2 * (takePotato.height + 5) + takePotato.height / 2;
			addChild(takePotato);
			
			var takeSunFlower:SimpleButton = new SimpleButton("Take Sun Flower", 20);
			takeSunFlower.x =  stage.stageWidth -  takeSunFlower.width / 2 - 4;
			takeSunFlower.y =  stage.stageHeight - takeSunFlower.height / 2 - 5;
			addChild(takeSunFlower);
			
			
			var makeMove:SimpleButton = new SimpleButton("Make A Move", 20);
			makeMove.x = stage.stageWidth / 2;
			makeMove.y = stage.stageHeight - makeMove.height / 2 - 5;
			addChild(makeMove);
			
			
			var menuButton:SimpleButton = new SimpleButton("Menu", 20);
			menuButton.x = stage.stageWidth - menuButton.width / 2 - 4;
			menuButton.y = menuButton.height / 2 + 5;
			addChild(menuButton);
				
			buttonArray.push(plantClover, plantPotato, plantSunFlower, takeClover, takePotato, takeSunFlower, makeMove, menuButton);
		}
			
		//Activate	
		public function initListeners():void 
		{
			plant.addEventListener(MouseEvent.MOUSE_DOWN, plant_mouseDown);
			_model.addEventListener(ModelEvent.ACTION_PROCESSED, actionProcessed);
				
			for (var i:int = buttonArray.length; i > 0; i--)
			{
				var button:SimpleButton = buttonArray[i - 1];
				button.addEventListener(ButtonEvent.BUTTON_PRESSED, button_buttonPressed, false, 0, true);
				button.enable();
			}
		}
			
		//Deactivate	
		public function removeListeners():void 
		{
			plant.removeEventListener(MouseEvent.MOUSE_DOWN, plant_mouseDown);
			_model.removeEventListener(ModelEvent.ACTION_PROCESSED, actionProcessed);
			
			for (var i:int = buttonArray.length; i > 0; i--)
			{
				var button:SimpleButton = buttonArray[i - 1];
				button.removeEventListener(ButtonEvent.BUTTON_PRESSED, button_buttonPressed, false);
				button.disable();
			}
		}
				
		//Show Results
		private function initHarvestResults():void
		{
			var harvest:Object = _model.result;
			
			_harvest["clover"] = harvest["clover"];
			_harvest["potato"] = harvest["potato"];
			_harvest["sunflower"] = harvest["sunflower"];
			
			
			var cloverString:String = "Clover: " + _harvest["clover"];
			var potatoString:String = "Potato: " + _harvest["potato"];
			var sunflowerString:String = "Sunflower: " + _harvest["sunflower"];
			
			cloverText = new InfoText(15, 0x31f0dd);
			cloverText.x = 5;
			cloverText.y = 3;
			cloverText.text = cloverString;
			addChild(cloverText);
			
			potatoText = new InfoText(15, 0x31f0dd);
			potatoText.x = 5;
			potatoText.y = 3 + cloverText.height;
			potatoText.text = potatoString;
			addChild(potatoText);
			
			sunflowerText = new InfoText(15, 0x31f0dd);
			sunflowerText.x = 5;
			sunflowerText.y = 3 + 2 * cloverText.height;
			sunflowerText.text = sunflowerString;
			addChild(sunflowerText);
			
			//getDatabase();
		}
				
		//Place Vegetables from DataBase
		private function getDatabase():void 
		{
			var obj:Object = _model.result;
			if (obj.hasOwnProperty("vegetablesOnPlant"))
			{
				var vector: Vector.<VegetableProperty> = obj["vegetablesOnPlant"];
				for (var i:int = 0; i < vector.length; i++)
				{
					var property:VegetableProperty = vector[i];
					var url:String = "../bin/res/";
					url = String(url + property.type +"/" + property.phase + ".png")
					var vegetable:ResourseLoader = getVegetable(url) as ResourseLoader;
					vegetable.x = property.x;
					vegetable.y = property.y;
					plant.addChild(vegetable);
					_vegetables.push(vegetable);
					vegIndex.push(property.phase);
				}
			}
		}
		
		//Update results and send it to Model
		private function changeResult():void
		{
			var cloverString:String = "Clover: " + _harvest["clover"];
			var potatoString:String = "Potato: " + _harvest["potato"];
			var sunflowerString:String = "Sunflower: " + _harvest["sunflower"];
			
			cloverText.text = cloverString;
			potatoText.text = potatoString;
			sunflowerText.text = sunflowerString;
			
			_model.result = _harvest;
		}
		
		//Remove before leave game
		public function removeAll():void
		{
			removeListeners();
			while (this.numChildren > 0)
				removeChildAt(0);
		}
		
		//To Do A Moving 
		private function makeMove():void 
		{
			for (var i:int = 0; i < vegIndex.length; i++)
			{
				if (vegIndex[i] < 5)
				{
					vegIndex[i]++;
					var oldVegetable:ResourseLoader = _vegetables[i];
					plant.removeChild(oldVegetable);
					var newUrl:String = oldVegetable.url;
					newUrl = newUrl.slice(0, newUrl.length - 5);
					newUrl = String(newUrl + vegIndex[i] + ".png");
					
					var newVegetable:ResourseLoader = getVegetable(newUrl) as ResourseLoader;
					newVegetable.x = oldVegetable.x;
					newVegetable.y = oldVegetable.y;
					plant.addChild(newVegetable);
					_vegetables[i] = newVegetable;
				}
			}
		}
		
		//Load a new texture, or take an existing
		private function getVegetable(url:String): ResourseLoader
		{
			var vegetable: ResourseLoader;
			for each(var item:ResourseLoader in resourses)
			{
				//Check is texture loaded
				if (item.url == url)
				{
					vegetable = new ResourseLoader;
					var loader: Loader = item.loader;
					var loaderBitmap: Bitmap = loader.content as Bitmap;
					var bitmap: Bitmap = new Bitmap(loaderBitmap.bitmapData);
					bitmap.x = loaderBitmap.x;
					bitmap.y = loaderBitmap.y;
					vegetable.url = item.url;
					vegetable.addChild(bitmap);
					return vegetable;
				}
			}
			
			vegetable = new ResourseLoader(url);
			vegetable.addEventListener(Event.COMPLETE, onComplete);
			return vegetable;
		}
			
		//Switch gathering	
		private function gatherVagetables(type:String):void 
		{
			switch (type)
			{
				case "clover":
					gatherClover(type);
					break;
				case "potato":
					gatherPotato(type);
					break;
				case "sunflower":
					gatherSunFlower(type);
					break;
			}
		}
		
		//Gather a ripe Sun Flower
		private function gatherSunFlower(type:String):void 
		{
			for (var i:int = _vegetables.length - 1; i > -1; i--)
			{
				var item:ResourseLoader = _vegetables[i];
				var index:int = vegIndex[i];
				if (item.url.indexOf(type) != -1 && index == 5)
				{
					plant.removeChild(item);
					_vegetables.splice(i, 1);
					vegIndex.splice(i, 1);
					_harvest["sunflower"]++;
				}
			}
			changeResult();
		}
			
		//Gather a ripe Potato
		private function gatherPotato(type:String):void 
		{
			for (var i:int = _vegetables.length - 1; i > -1; i--)
			{
				var item:ResourseLoader = _vegetables[i];
				var index:int = vegIndex[i];
				if (item.url.indexOf(type) != -1 && index == 5)
				{
					plant.removeChild(item);
					_vegetables.splice(i, 1);
					vegIndex.splice(i, 1);
					_harvest["potato"]++;
				}
			}
			changeResult();
		}
		
		//Gather a ripe Clover
		private function gatherClover(type:String):void 
		{
			for (var i:int = _vegetables.length - 1; i > -1; i--)
			{
				var item:ResourseLoader = _vegetables[i];
				var index:int = vegIndex[i];
				if (item.url.indexOf(type) != -1 && index == 5)
				{
					plant.removeChild(item);
					_vegetables.splice(i, 1);
					vegIndex.splice(i, 1);
					_harvest["clover"]++;
				}
			}
			changeResult();
		}
			
//--------------------------------------------------------------------------
//
//  Event handlers
//
//--------------------------------------------------------------------------
		
		//Waiting loading before pulling
		private function onComplete(e:Event):void 
		{
			var vegetable:ResourseLoader = e.target as ResourseLoader;
			resourses.push(vegetable);
		}
		
		//To Plant Vegetable Under Mouse and send request
		private function vegetable_click(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, vegetable_mouseMove);
			stage.removeEventListener(MouseEvent.RIGHT_CLICK, vegetable_click);
			Mouse.show();
			
			var vegetable: ResourseLoader = _vegetables[_vegetables.length - 1];
			var type:String;
			var phase:int = vegIndex[vegIndex.length - 1];
			var _x:int = vegetable.x;
			var _y:int = vegetable.y;
			
			if (vegetable.url.indexOf("clover") != -1)
				type = "clover";
			else if (vegetable.url.indexOf("potato") != -1)
				type = "potato";
			else if (vegetable.url.indexOf("sunflower") != -1)
				type = "sunflower";
			
			var properties:VegetableProperty = new VegetableProperty(type, phase, _x, _y);
			_controller.sendRequest(properties);
			
		}
		
		//Drag Vegetable
		private function vegetable_mouseMove(e:MouseEvent):void 
		{
			var vegetable: ResourseLoader = _vegetables[_vegetables.length - 1];
			vegetable.x = plant.mouseX;
			vegetable.y = plant.mouseY;
			e.updateAfterEvent();
		}
		
		//Check Plant is loaded 
		private function groundLoadComplete(e:Event):void 
		{
			var ground: ContentLoader = e.target as ContentLoader
			ground.removeEventListener(Event.COMPLETE, groundLoadComplete);
			plant.addChild(ground);
			plant.x = ( - plant.width + stage.stageWidth) / 2;
			plant.y = ( - plant.height + stage.stageHeight) / 2;
		}
		
		//On Start Dragging Plant
		private function plant_mouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			plant.mouseChildren = false;
			plant.buttonMode = true;
			mouseX0 = stage.mouseX;
			mouseY0 = stage.mouseY;
		}
		
		//Stop Dragging Plant
		private function stage_mouseUp(e:MouseEvent):void 
		{
			plant.mouseChildren = true;
			plant.buttonMode = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseMove(e:MouseEvent):void 
		{
			//Drag
			var xx:Number = mouseX0 - stage.mouseX;
			var yy:Number = mouseY0 - stage.mouseY;
				
			plant.x -= xx;
			plant.y -= yy;
				
			//Drag Limit
			if (plant.x > 0)
				plant.x = 0;
			if (plant.y > 0)
				plant.y = 0;
			if	(plant.x < stage.stageWidth - plant.width)
				plant.x = stage.stageWidth - plant.width;
			if (plant.y < stage.stageHeight - plant.height)
				plant.y = stage.stageHeight - plant.height;
					
			mouseX0 = stage.mouseX;
			mouseY0 = stage.mouseY;
			e.updateAfterEvent();
		}
		
		//Model Handler
		private function actionProcessed(e:ModelEvent):void 
		{
			var obj:Object = e.result as Object;
			
			//New Vegetable
			if (obj.hasOwnProperty("newVegatable"))
			{
				var url:String;
				url = obj["newVegatable"];
				var vegetable:ResourseLoader = getVegetable(url) as ResourseLoader;
				vegetable.x = plant.mouseX;
				vegetable.y = plant.mouseY;
				plant.addChild(vegetable);
				_vegetables.push(vegetable);
				vegIndex.push(1);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, vegetable_mouseMove);
				stage.addEventListener(MouseEvent.RIGHT_CLICK, vegetable_click);
				Mouse.hide();
			}
			
			//To Move
			if (obj["move"])
			{
				makeMove();
			}
			
			//Gathering
			if (obj.hasOwnProperty("takeVegetables"))
			{
				var type:String;
				type = obj["takeVegetables"];
				gatherVagetables(type);
			}
			
		}
		
		private function button_buttonPressed(e:ButtonEvent):void 
		{
			//Pass to controller
			_controller.onAction(e.label); 
		}
		
//--------------------------------------------------------------------------
//
//  Getters and Setters
//
//--------------------------------------------------------------------------
		
		public function get vegetables():Vector.<ResourseLoader>
		{
			return _vegetables;
		}
		
		public function set vegetables(value:Vector.<ResourseLoader>):void
		{
			_vegetables = value;
		}
		
		public function get indexes():Vector.<int>
		{
			return vegIndex;
		}
		
		public function set indexes(value:Vector.<int>):void
		{
			vegIndex = value;
		}
		
		public function get harvest():Object
		{
			return _harvest;
		}
		
		public function set harvest(value:Object):void
		{
			_harvest = value;
			changeResult();
		}
    }

}