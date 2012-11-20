package components 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...Load Content Class
	 * @author Leonid Trofimchuk
	 */
	public class ResourseLoader extends Sprite 
	{
		private var _url:String;
		private var urlReq:URLRequest;
		private var _loader:Loader;
		public function ResourseLoader(url:String = null)
		{
			if (url)
			{
				_loader = new Loader();
				_url = url;
				urlReq = new URLRequest(_url);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
				_loader.load(urlReq);
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------
		
		private function complete(e:Event):void 
		{
			var content: Loader = e.target.loader as Loader;
			content.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
			var bitmap:Bitmap = content.content as Bitmap;
			bitmap.x = - content.width / 2;
			bitmap.y = - content.height;
			addChild(bitmap);
			dispatchEvent(e);
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Getters and Setters
//
//-------------------------------------------------------------------------------------------------	
		
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			 _url = value;
		}
		
		public function get loader():Loader
		{
			return _loader;
		}
		
		public function set loader(value:Loader):void
		{
			_loader = value;
		}
	}

}