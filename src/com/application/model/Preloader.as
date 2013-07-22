package com.application.model
{
	// -------------------------------------------------------------------------------------------------------------------------------
	import com.darcey.debug.Ttrace;
	import com.darcey.events.CustomEvent;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	// -------------------------------------------------------------------------------------------------------------------------------
	
	
	
	// -------------------------------------------------------------------------------------------------------------------------------
	public class Preloader extends EventDispatcher
	{
		// Singleton -----------------------------------------------------------------------------------------------------------------
		private static var Singleton:Preloader;
		public static function getInstance():Preloader { if ( Singleton == null ){ Singleton = new Preloader(); } return Singleton;}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private var t:Ttrace;
		public var loader:LoaderMax;
		private var params:Object;
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public function Preloader()
		{
			// Setup class specific tracer
			t = new Ttrace(true);
			t.ttrace("Preloader()");
			
			params = new Object();
			params.percentLoaded = 0;
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public function start():void
		{
			t.ttrace("Preloader.start()");
	
			// Setup Greensocks LoaderMax
			loader = new LoaderMax( { 
				name:"que1",
				maxConnections:5,
				auditSize:true,
				onProgress:preloaderProgressHandler,
				onError:preloaderErrorHandler,
				onComplete:preloaderCompleteHandler
			} );
			
			
			// Add the two images we want preloaded to our loaderMax (preloader)
			//http://www.greensock.com/as/docs/tween/com/greensock/loading/DataLoader.html
			//preloader.append( new DataLoader("assets/city.obj",{ name:"model",format:"text",estimatedBytes:(7381*1024) } ));
			//loader.append( new DataLoader("assets/models/arrow/arrows.obj",{ name:"arrowsModel",format:"text",estimatedBytes:(204*1024) } ));
			//loader.append( new ImageLoader(Variables.targetDir + "/assets/images/fsb.png",{ name:"fsb",estimatedBytes:(4*1024) } ));
			
			loader.append( new ImageLoader("assets/negx.jpg",{ name:"negx",estimatedBytes:(200*1024) } ));
			loader.append( new ImageLoader("assets/negy.jpg",{ name:"negy",estimatedBytes:(200*1024) } ));
			loader.append( new ImageLoader("assets/negz.jpg",{ name:"negz",estimatedBytes:(200*1024) } ));
			loader.append( new ImageLoader("assets/posx.jpg",{ name:"posx",estimatedBytes:(200*1024) } ));
			loader.append( new ImageLoader("assets/posy.jpg",{ name:"posy",estimatedBytes:(200*1024) } ));
			loader.append( new ImageLoader("assets/posz.jpg",{ name:"posz",estimatedBytes:(200*1024) } ));
			
			// Start preloader
			loader.load();
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function preloaderProgressHandler(e:LoaderEvent):Number
		{
			var percentLoaded:Number = Math.round(e.target.progress * 100);
			
			//signature.update("Loading Data: " + percentLoaded + "%");
			params.percentLoaded = percentLoaded;
			dispatchEvent( new CustomEvent("preloader progress event",params) );
			return percentLoaded;
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function preloaderErrorHandler(e:LoaderEvent):void
		{
			t.div();
			t.force("########## ERROR #############");
			t.force("Preloader.preloaderErrorHandler(e):");
			t.force("target: [" + e.target + "]");
			t.force("text: [" + e.text + "]");
			t.force("Preloader.errorHandler(): Check your file paths and if your on a windows server ensure f4v mime type is added.");
			t.div();
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function preloaderCompleteHandler(e:LoaderEvent):void
		{
			t.ttrace("Preloader.preloaderCompleteHandler(e)");
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		// --------------------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------------------
		public function getBitmapDataByLoaderName(name:String):BitmapData
		{
			t.ttrace("Preloader.getBitmapDataByLoaderName(name:"+name+")");
			
			var bmpData:BitmapData;
			var imgLoader:ImageLoader = loader.getLoader(name); // LoaderMax
			bmpData = imgLoader.rawContent.bitmapData;
			
			return bmpData;
		}
		// --------------------------------------------------------------------------------------------------------------------------
		
	}
	// -------------------------------------------------------------------------------------------------------------------------------
}