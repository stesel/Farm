package 
{
	import components.ContentLoader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Security;
	import states.StateManager;
	
	[SWF(backgroundColor = "#286a55", frameRate = "60", width = "800", height = "600")]
	[Frame(factoryClass = "Preloader")]
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Main extends Sprite 
	{
		private var stateManager:StateManager;				 		//State Manager
		
		public function Main():void 
		{
			if (stage)
				init();
			else 
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			Security.loadPolicyFile("crossdomain.xml");
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			initStateManager();
		}
		
		private function initStateManager():void 
		{
			stateManager = new StateManager();
			addChild(stateManager);
		}
	}
	
}