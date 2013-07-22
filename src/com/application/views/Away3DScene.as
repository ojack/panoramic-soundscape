package com.application.views
{
	// --------------------------------------------------------------------------------------------------------------
	import com.application.model.Variables;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Vector3D;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;

	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.debug.WireframeAxesGrid;
	import away3d.lights.DirectionalLight;
	import away3d.materials.lightpickers.StaticLightPicker;


	// --------------------------------------------------------------------------------------------------------------
	
	
	// --------------------------------------------------------------------------------------------------------------
	public class Away3DScene extends Sprite
	{		
		// Singleton -----------------------------------------------------------------------------------------------------------------
		private static var Singleton:Away3DScene;
		public static function getInstance():Away3DScene { if ( Singleton == null ){ Singleton = new Away3DScene(); } return Singleton;}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		// Var ini
		//private var t:Ttrace;
		
		// Away3D4 Vars
		public var scene:Scene3D;
		public var camera:Camera3D;
		public var view:View3D;
		
		// Some default lights
		public var staticLightPicker:StaticLightPicker;
		public var directionalLight:DirectionalLight;
		
		// Away3D4 Camera handling variables (Hover camera)
		public var hoverController:HoverController;
		private var move:Boolean = false;
		private var autoScroll:Boolean = false;
		private var lastPanAngle:Number = 0;
		private var lastTiltAngle:Number = 0;
		private var lastMouseX:Number = 0;
		private var lastMouseY:Number = 0;
		
		// Helpers
		private var stats:AwayStats;
		private var trident:Trident;
		private var axesGrid:WireframeAxesGrid;
		private var outputBox:TextField;
		
		// Init Config
		private var _showStats:Boolean = false;
		private var _showTrident:Boolean = false;
		private var _showAxesGrid:Boolean = false;
		
		// Config
		private var cameraViewDistance:Number = 500000;
		private var cameraZ:Number = 5000;
		//private var cameraZ:Number = 5;
		private var antiAlias:Number = 3;
		private var startingPanAngle:Number = 180;
		private var startingTiltAngle:Number = 0;
		private var panDir:Number = 1;
		
		private var centerX:Number;
		private var centerY:Number;

		private var objectX:Number = 0;
		private var objectY:Number = 0;
		private var currObject:ObjectContainer3D;
		private var title_text:TextField = new TextField();
		
		private var maxField:Number = 100;
		private var minField:Number = 50;
		private var startField:Number = 80;
		private var zooming:Boolean = false;
		public var render:Boolean = true; // Turn rendering on and off as and when you see fit
		
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		public function Away3DScene()
		{
			//t = new Ttrace(false);
			//t.ttrace("Away3DScene()");
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			centerX = 720;
			centerY = 450;
			objectX = centerX;
			objectY = centerY;
			
			outputBox = new TextField();
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		public function init(startingPanAngle:Number=180,startingTiltAngle:Number=10,cameraZ:Number = 5000,showStats:Boolean=false,showTrident:Boolean=false,showAxesGrid:Boolean=false):void
		{
			//t.ttrace("Away3DScene().init()");
			
			
			_showStats = false;
			_showTrident = showTrident;
			_showAxesGrid = showAxesGrid;
			
			this.cameraZ = cameraZ;
			
			this.startingPanAngle = startingPanAngle;
			this.startingTiltAngle = startingTiltAngle;
			this.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		// --------------------------------------------------------------------------------------------------------------
		
		public function getView():View3D{
			return view;
		}
		
		// --------------------------------------------------------------------------------------------------------------
		private function addedToStageHandler(e:Event):void
		{
			//t.ttrace("Away3DScene.addedToStageHandler(e)");
			
			this.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			
			initAway3D();
		}
		// --------------------------------------------------------------------------------------------------------------
		public function resetScene():void
		{
			autoScroll = true;
			hoverController.tiltAngle = 0;
		}
		
		// --------------------------------------------------------------------------------------------------------------
		private function initAway3D():void
		{
			//t.ttrace("Away3DScene.initAway3D()");
			
			// Check Stage3D is available
			if (!isStage3DAndContextAvailable()){ return; }
			
			// Setup scene
			scene = new Scene3D();
			
			// Setup camera
			camera = new Camera3D();
			//camera.lens.far = cameraViewDistance;
			camera.lens = new PerspectiveLens (75); 
			
			// Setup view
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.antiAlias = antiAlias;
			addChild(view);
			
			// process stats, trident and axes grid
			if (_showStats){
				showStats();
			}
			
			if (_showTrident){
				showTrident();
			}
			
			if (_showAxesGrid){
				showAxesGrid();
			}
			
			// Setup HoverController
			hoverController = new HoverController(camera, null, startingPanAngle, startingTiltAngle , cameraZ);			
			
			// Setup lights
			setupDirectonalLight();
			
			// Setup event listeners
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			// Setup Away3D 4 SWF Resize Hand
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
			
			stage.addEventListener(Event.ENTER_FRAME,renderHandler);
			//showZoomInfo();
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ---------------------------------------------------------------------------------------------------------
		public function setupDirectonalLight():void
		{
			directionalLight = new DirectionalLight();
			directionalLight.direction = new Vector3D(2000,-2000,5000);
			directionalLight.specular = 0.2;
			scene.addChild(directionalLight);
			
			staticLightPicker = new StaticLightPicker([directionalLight]);
		}
		// ---------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		private function renderHandler(e:Event):void
		{
			
				//(view.camera.lens as PerspectiveLens).fieldOfView = 5;
				if(move){
				var panUpdate:Number = 0.3 * (stage.mouseX - lastMouseX)/4 + lastPanAngle;
				hoverController.panAngle = panUpdate;
				var tiltUpdate:Number = 0.3 * (stage.mouseY - lastMouseY)/4;
				/*Restrict tilt to not point directly at the sky or directly at the ground*/
				if(tiltUpdate > 0){
					if(hoverController.tiltAngle < 45){
						hoverController.tiltAngle = tiltUpdate + lastTiltAngle;
					}
				} else {
					if(hoverController.tiltAngle > -45){
						hoverController.tiltAngle = tiltUpdate + lastTiltAngle;
					}
				}
				
				
				trace("tilt = "+ hoverController.tiltAngle);
				}
				if(autoScroll==true){
					//var panUpdate:Number = 0.3 * (stage.mouseY - lastMouseX)/4;
					hoverController.panAngle += 0.1;
					//hoverController.tiltAngle = 0;
					//lastPanAngle = hoverController.panAngle;
				}
				//view.camera.moveForward(400);
				
			
			view.render();
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		private function resizeHandler(e:Event=null):void
		{
			if (!render){ return; }
			
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		public function zoomToObject(object:ObjectContainer3D):void
		{
			currObject = object;
			zooming = true;
		//view.camera.lookAt(target);
			
		trace(hoverController.distance);
		
		
		}
		
		private function onZoom(e:TransformGestureEvent):void
		{
			/*_container.scaleX *= e.scaleX;
			_container.scaleY *= e.scaleY; 
			_container.scaleZ *= e.scaleY;*/
		
			//(view.camera.lens as PerspectiveLens).fieldOfView -= 1;
			(view.camera.lens as PerspectiveLens).fieldOfView -=10;
			
			showZoomInfo();
		}
		public function setZoom(zoom:Number):void
		{
			 title_text.text = zoom + " zoom called by soundstation";
			 var newZoom:Number = (view.camera.lens as PerspectiveLens).fieldOfView + zoom;
			 if(newZoom > 40){
			 	if(newZoom < 95)
				{
				(view.camera.lens as PerspectiveLens).fieldOfView =newZoom;
				}
		}
		}
		
		public function setPan(e:TransformGestureEvent):void{
							   hoverController.panAngle -= e.offsetX;
		hoverController.tiltAngle-= e.offsetY;
		title_text.text = "pan of :"+e.offsetX + "called by " +e.type;
		
		}
		
		// ---------------------------------------------------------------------------------------------------------
		public function showStats(minimised:Boolean=true,scale:Number=1):void
		{
			//t.ttrace("Away3DSetup().showStats()");
			
			stats = new AwayStats(view,minimised);
			stats.x = 5;
			stats.y = 5;
			stats.scaleX = stats.scaleY = scale;
			outputBox.y = 300;
			outputBox.x = 600;
			outputBox.width = 500;
			outputBox.height = 400;
			outputBox.text = "THIS IS WHERE YOUR INFO WILL GO";
			//this.addChild(outputBox);
			
			this.addChild(stats);
		}
		// ---------------------------------------------------------------------------------------------------------
		
		private function showZoomInfo():void
		{
			
			
			/*
			var title_form:TextFormat = new TextFormat();
			title_form.size = 18;
			title_form.font = "BentonSansComp";
			title_form.color = 0x000000;
			
			
			title_text.defaultTextFormat = title_form;
			title_text.embedFonts = true;
			//title_text.antiAliasType = AntiAliasType.ADVANCED;
			title_text.width = 800;
			title_text.height = 100;
			title_text.x = -30;
			title_text.y = 900;
			title_text.text = "zoom called!: "+(view.camera.lens as PerspectiveLens).fieldOfView + "pan: "+hoverController.panAngle;
			addChild(title_text);*/
		}
		// ---------------------------------------------------------------------------------------------------------
		public function hideStats():void
		{
			//t.ttrace("Away3DSetup().showStats()");
			
			if (stats){
				stats.visible = false;
			}
		}
		// ---------------------------------------------------------------------------------------------------------
		
		
		
		
		// ---------------------------------------------------------------------------------------------------------
		public function showTrident(length:Number = 900,showLetters:Boolean=true):void
		{
			//t.ttrace("Away3DScene.showTrident(length)");
			
			
			trident = new Trident(length,showLetters);
			//trident.scaleX = trident.scaleY = trident.scaleZ = 0.2;
			view.scene.addChild(trident);
		}
		// ---------------------------------------------------------------------------------------------------------
		// ---------------------------------------------------------------------------------------------------------
		public function hideTrident():void
		{
			//t.ttrace("Away3DSetup().hideTrident()");
			
			if (trident){
				trident.visible = false;
			}
		}
		// ---------------------------------------------------------------------------------------------------------
		
		
		
		// ---------------------------------------------------------------------------------------------------------
		public function showAxesGrid(subDivision:uint = 10, gridSize:uint = 2500):void
		{
			//t.ttrace("Away3DSetup().showAxesGrid()");
			
			axesGrid = new WireframeAxesGrid(subDivision,gridSize,1);
			view.scene.addChild(axesGrid);
		}
		// ---------------------------------------------------------------------------------------------------------
		// ---------------------------------------------------------------------------------------------------------
		public function hideAxesGrid():void
		{
			//t.ttrace("Away3DSetup().showAxesGrid()");
			
			if (axesGrid){
				axesGrid.visible = false;
			}
		}
		// ---------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
	
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		private function mouseDownHandler(e:MouseEvent):void
		{
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			autoScroll = false;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		// --------------------------------------------------------------------------------------------------------------
		private function mouseUpHandler(e:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		// --------------------------------------------------------------------------------------------------------------
		private function onStageMouseLeave(e:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		public function isStage3DAndContextAvailable():Boolean
		{
			var stage3DAvailable:Boolean = ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D");
			if (!stage3DAvailable){
				var msg:String = "Away3DScene.isStage3DAndContextAvailable(): STAGE3D is not available - please ensure you have WMODE = DIRECT setup in your SWF embedding code and that you have Flash Player 11 Installed!";
				//t.warn(msg);
				//t.error(msg);
				return false;
			} else {
				return true;
			}
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		
		
	}
	// --------------------------------------------------------------------------------------------------------------
}