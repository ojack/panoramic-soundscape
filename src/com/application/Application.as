package com.application
{
	// ---------------------------------------------------------------------------------------------------
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	
	import com.application.model.Preloader;
	import com.application.views.Away3DScene;
	import com.darcey.debug.Ttrace;
	import com.darcey.events.CustomEvent;
	import com.darcey.ui.FullScreenButton;
	import com.darcey.ui.Signature;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	// ---------------------------------------------------------------------------------------------------
	
	
	
	// ---------------------------------------------------------------------------------------------------
	public class Application extends Sprite
	{
		// -----------------------------------------------------------------------------------------------
		private var t:Ttrace;
		
		private var away3DScene:Away3DScene;
		private var signature:Signature;
		private var fsb:FullScreenButton;
		
		private var preloader:Preloader;
		private var bitmapCubeTexture:BitmapCubeTexture;
		private var skyBox:SkyBox;
		// -----------------------------------------------------------------------------------------------
		
		
		
		// -----------------------------------------------------------------------------------------------
		public function Application()
		{
			// Setup class specific tracer
			t = new Ttrace(true);
			t.ttrace("Application()");
			
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		
		// -----------------------------------------------------------------------------------------------
		public function init(e:Event=null):void
		{
			t.ttrace("Application.init(e)");
			
			// Clean up stage added listener
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
			
			// Setup signature
			signature = new Signature();
			signature.update("Darcey@AllForTheCode.co.uk - Developer Examples - Hold left mouse and drag to rotate scene.");
			addChild(signature);
			
			// We are preloading content on this one, I hate embedding stuff!
			preloader = new Preloader();
			preloader.addEventListener("preloader progress event",preloaderProgressHandler);
			preloader.addEventListener(Event.COMPLETE,preloaderCompleteHandler);
			preloader.start();
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		// -----------------------------------------------------------------------------------------------
		private function preloaderProgressHandler(e:CustomEvent):void
		{
			signature.update("Darcey@AllForTheCode.co.uk - Developer Examples - Loading assets: " + e.params.percentLoaded + "%");
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		// -----------------------------------------------------------------------------------------------
		public function preloaderCompleteHandler(e:Event):void
		{
			t.ttrace("Application.preloaderCompleteHandler(e)");
			
			// Do some spring cleaning... Listeners everywhere... Even under the sofa!
			preloader.removeEventListener(ProgressEvent.PROGRESS,preloaderProgressHandler);
			preloader.removeEventListener(Event.COMPLETE,preloaderCompleteHandler);
			
			// Lets get ready to rumble!
			
			// Setup Away3D 4
			setupAway3D();
			
			// Setup materials
			setupMaterials();
			
			// Build our Away3D 4 scene
			buildScene();
			
			// 2D
			buildUI();
			
			// Setup any listeneres for mouse, stage resizing, animation etc
			initEventListeners();
			
			// Final signature
			signature.update("Darcey@AllForTheCode.co.uk - Developer Examples - Left click and drag to rotate scene.");
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		
		
		

		// -----------------------------------------------------------------------------------------------
		private function setupAway3D():void
		{
			t.ttrace("Application.setupAway3D()");
			
			// Init Away3D
			away3DScene = Away3DScene.getInstance(); // Singleton instance of the Away3D 4 view
			away3DScene.init(175,-10,10);
			addChild(away3DScene)
			
			// Some additional configuration
			away3DScene.showStats();
			//away3DScene.showTrident(100);
			//away3DScene.showAxesGrid();
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		
		
		// -----------------------------------------------------------------------------------------------
		private function setupMaterials():void
		{
			t.ttrace("Application.setupMaterials()");
			
			bitmapCubeTexture = new BitmapCubeTexture(
				preloader.getBitmapDataByLoaderName("posx"),
				preloader.getBitmapDataByLoaderName("negx"),
				preloader.getBitmapDataByLoaderName("posy"),
				preloader.getBitmapDataByLoaderName("negy"),
				preloader.getBitmapDataByLoaderName("posz"),
				preloader.getBitmapDataByLoaderName("negz")
			);
		}
		// -----------------------------------------------------------------------------------------------
		
		
		

		// -----------------------------------------------------------------------------------------------
		private function buildScene():void
		{
			t.ttrace("Application.buildScene()");
			
			skyBox = new SkyBox(bitmapCubeTexture); // We feed it a BitmapCubeTexture even though 4.0.9 says give me a CubeMap
			away3DScene.scene.addChild(skyBox);
		}
		// -----------------------------------------------------------------------------------------------
		

		
		
		
		
		// -----------------------------------------------------------------------------------------------
		private function buildUI():void
		{
			t.ttrace("Application.buildUI()");
			
			fsb = new FullScreenButton();
			addChild(fsb);
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		
		// -----------------------------------------------------------------------------------------------
		private function initEventListeners():void
		{
			t.ttrace("Application.initEventListeners()");
			
			// Resize handler
			stage.addEventListener(Event.RESIZE,resizeHandler);
			resizeHandler();
			
			// Enter frame handler
			stage.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		// -----------------------------------------------------------------------------------------------
		
		
		
		
		
		
		// -----------------------------------------------------------------------------------------------
		private function enterFrameHandler(e:Event=null):void
		{
			
		}
		// -----------------------------------------------------------------------------------------------
		
		
		

		// -----------------------------------------------------------------------------------------------
		private function resizeHandler(e:Event=null):void
		{
			signature.x = 5;
			signature.y = stage.stageHeight - 25;
			
			fsb.x = (stage.stageWidth) - (fsb.width + 10);
			fsb.y = (stage.stageHeight) - (fsb.height + 10);
		}
		// -----------------------------------------------------------------------------------------------
		
		
	}
	// ---------------------------------------------------------------------------------------------------
}