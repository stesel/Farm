package components 
{
	/**
	 * ...Class collects vegetable properties
	 * @author Leonid Trofimchuk
	 */
	public class VegetableProperty 
	{
		private var _type:String;		//Type of Vegetable
		private var _phase:int;			//Growth Phase
		private var _x:int;				//X coordinate on Plant
		private var _y:int;				//Y coordinate on Plant
		
		/**
		 * ...Constructor
		 * @param	type		Type of Vegetable
		 * @param	phase		Growth Phase
		 * @param	x			X coordinate on Plant
		 * @param	y			Y coordinate on Plant
		 */
		public function VegetableProperty(type:String = null, phase:int = 1, x:int = 0, y:int = 0) 
		{
			_type = type;
			_phase = phase;
			_x = x;
			_y = y;
		}
		
//--------------------------------------------------------------------------
//
//  Getters and setters
//
//--------------------------------------------------------------------------
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get phase():int
		{
			return _phase;
		}
		
		public function set phase(value:int):void
		{
			_phase = value;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
	}

}