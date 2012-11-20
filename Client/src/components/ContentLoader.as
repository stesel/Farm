package components 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...Load Content Class
	 * @author Leonid Trofimchuk
	 */
	public class ContentLoader extends Loader 
	{
		private var _url:String;
		private var urlReq:URLRequest;
		public function ContentLoader(url:String = null) 
		{
			if (url)
			{
				_url = url;
				urlReq = new URLRequest(_url);
				contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
				load(urlReq);
			}
		}
		
//-------------------------------------------------------------------------------------------------
//
//  Events handlers
//
//-------------------------------------------------------------------------------------------------
		
		private function complete(e:Event):void 
		{
			contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
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
		
	
	}

}