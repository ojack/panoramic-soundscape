/*

Interactive soundScape developed for the California Gallery of Natural Sciences at Oakland Museum of California.

The interactive uses the following external libraries and classes:

Away3d -- 3D rendering engine https://code.google.com/p/asaudio/
AsAudio -- Sound processing library
TweenLite and TweenMax -- user interface transitions

6/25/13
*/

package
{
	import com.application.views.Away3DScene;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Group;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;
	
	[SWF(backgroundColor="#000000", width="1920", height="1080", frameRate="60", quality="HIGH")]
	
	public class Soundstation extends Away3DScene
	{
	/// Environment map source images. Images form a six-sided cube that is rendered as a Skybox using Away3d 
		
		
		[Embed(source="assets/joePano/joe_f.jpg")]//front
		private var EnvPosZ:Class;
		[Embed(source="assets/joePano/joe_u.jpg")]//up
		private var EnvPosY:Class;
		[Embed(source="assets/joePano/joe_l.jpg")]//left
		private var EnvNegX:Class;
		[Embed(source="assets/joePano/joe_b.jpg")]//back
		private var EnvNegZ:Class;
		[Embed(source="assets/joePano/joe_d.jpg")]//down
		private var EnvNegY:Class;
		[Embed(source="assets/joePano/joe_r.jpg")]//right
		private var EnvPosX:Class;
		
		
		//Embed Fonts
		[Embed(source="assets/BentonSans/BentonSans-Regular.otf", fontFamily="BentonSansReg", embedAsCFF="false", mimeType="application/x-font-truetype")]
		public var BentonSansReg:Class;
		[Embed(source="assets/BentonSans/BentonSansComp-Medium.otf", fontFamily="BentonSansComp", embedAsCFF="false", mimeType="application/x-font-truetype")]
		public var BentonSansComp:Class;
		
		
		//scene objects
		private var _skyBox:SkyBox; 
		
		private var myXMLLoader:URLLoader = new URLLoader();
		private var numCharacters:Number;
		private var soundList:XMLList;
		private var soundObjects:Array;
		private var selectedSounds:Number;
		
		private var soundscape:Sprite;
		private var soundGroup:Group;
		private var away3DScene:Away3DScene;
	

		private var _sphere:Mesh;
	
		private var popup:Loader = new Loader();
		private var window:Sprite;
		
		private var textContainer:Sprite;
		private var soundWave:Sprite;
		private var windowTween:TweenMax;
		private var dotTween:TweenMax;
		private var controlTween:TweenLite;
		private var ring:Sprite;
		private var windowCenter:Point;
		private var imageLoader:Loader;
		
		private var shade:Sprite;
		
		//Constants
		private var maxWidth:Number = 1000;//maximum distance in from origin for sound objects, in 3d space
		private var infoDiameter:Number = 900;//diameter of info window when it appears
		private var edgeMargin:Number = 60;//margin on all sides when window appears
		private var windowRadius:Number = 755;
		private var currScale:Number = 1;
		private var selectionMode:Boolean = false;//true when user is zoomed in on a sound
		//private var timer:Timer = new Timer(100000);
		private var timer:Timer = new Timer(100000);
		/**
		 * Constructor
		 */
		public function Soundstation()
		{
			/*set up stage */
			stage.displayState="fullScreen";
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			windowCenter = new Point(903, stage.stageHeight/2); //center point of circular display window. panning and volume are calculated in relation to this point
			
			/*Create new Away3d scene*/
			away3DScene = Away3DScene.getInstance(); // Singleton instance of the Away3D 4 view
			away3DScene.init(175,-10,10);
			addChild(away3DScene); 
			
			/*Draw skybox panorama*/
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(EnvPosX), Cast.bitmapData(EnvNegX), Cast.bitmapData(EnvPosY), Cast.bitmapData(EnvNegY), Cast.bitmapData(EnvPosZ), Cast.bitmapData(EnvNegZ));
			_skyBox = new SkyBox(cubeTexture);
			away3DScene.scene.addChild(_skyBox);
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			this.addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
			this.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
			this.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			timer.addEventListener(TimerEvent.TIMER, timerListener);
			
			/*Load sounds from external xml file*/
			myXMLLoader.load(new URLRequest("../assets/sounds_5_24.xml"));
			myXMLLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		/*Event handler for processing XML information once the file has been parsed*/
		private function processXML (e:Event):void{
			var myXML:XML = new XML(e.target.data);
			soundList = myXML.CHARACTER; //store xml data
			numCharacters = soundList.length();//number of audio elements
			drawWindow(); 
			loadSounds(); 
			away3DScene.resetScene();
			timer.start();
		}
		
		/*Draws basic graphics*/
		private function drawWindow():void
		{
			/*Full Screen overlay*/
			shade = new Sprite();//semi-transparent background
			shade.graphics.beginFill(0xFFFFFF, 0.5);
			shade.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			imageLoader = new Loader();
			var image:URLRequest = new URLRequest("../assets/popup14.png"); //load default screen graphic
			imageLoader.load(image);
			shade.addChild(imageLoader);
			addChild(shade);
		
			/*Circular Mask for viewing panorama*/
			window = new Sprite();
			window.graphics.beginFill(0x000000);
			window.graphics.drawCircle(0, 0, windowRadius);
			window.x = windowCenter.x;
			window.y = windowCenter.y;
			addChild(window);
			this.blendMode = "layer";
			window.blendMode = "erase";
		}
		
	
	
		
		private function loadSounds():void{
			soundGroup = new Group();//new AsAudio group, allowing sound volume to be controlled globally
			soundObjects = new Array(numCharacters); //array of sound objects for each sound
			selectedSounds = 0;
			for (var i:Number = 0; i < numCharacters; i++){
				var sound_url:String = soundList[i].@URL;
				var currTrack:Track = new Track(sound_url, String(i));
				
				/*New sound object--storing audio and text information for each species. 3d position is calculated separatey through SoundSphere class*/
				var soundObject:SoundObject = new SoundObject(soundList[i].@URL, soundList[i].@DESC, i, soundList[i].@SPECIES, soundGroup, soundList[i].@IMG_URL, windowCenter, soundList[i].@WAVE, soundList[i]);
				soundObject.name = String(i);
				soundObject.addEventListener(MouseEvent.CLICK, showInfo);
				soundObjects[i] = soundObject;
				addChild(soundObjects[i]);
				
				addSoundSphere(soundList[i].@ZONE);//Away3d object that keeps track of position in 3d space
			}
		}
		
	
		
		/*Add a SoundSphere object to the Away3D scene to keep track of the 3d position for each sound Object*/
		private function addSoundSphere(zone):void{
			var soundSphere:SoundSphere = new SoundSphere(maxWidth, zone);
			_skyBox.addChild(soundSphere);
		}
		
		/*Event handler called when a soundObject is selected via touch*/
		protected function showInfo(event:MouseEvent):void
		{
			timer.reset();
			timer.start();
			if(!selectionMode){
				selectionMode = true;
				
				selectedSounds = event.target.name;
				var infoX:Number = soundObjects[event.target.name].x;
				var infoY:Number = soundObjects[event.target.name].y;
				var infoRad:Number = infoDiameter/2;
			
				/*keep info window within bounds of screen*/
				if((infoX - infoRad-edgeMargin-300) < 0){
					infoX = infoRad + edgeMargin*2+300;
				} else if ((infoX + infoRad +edgeMargin) > stage.stageWidth){
					infoX= stage.stageWidth - infoRad - edgeMargin*2;
				}
			
				infoY = stage.stageHeight - infoRad - edgeMargin;
			
				/*Show Soundwave*/
				soundObjects[selectedSounds].wave.y = 0;
				soundObjects[selectedSounds].waveScrub.y = 170;
				soundObjects[selectedSounds].ShowInfo(infoX, infoY, infoDiameter);
			
				addChild(soundObjects[selectedSounds].wave);
				addChild(soundObjects[selectedSounds].waveScrub);
			
				/*Tween graphics, stop playing all sounds except the selected sound*/
				isolateSound(event.target.name);
				windowTween = TweenMax.to(window, 1, {x:infoX, y:infoY, width: infoDiameter-40, height:infoDiameter-40,  onComplete:addEventHandler, onReverseComplete:removeEventHandler});
				dotTween = TweenMax.to(soundObjects[selectedSounds], 1, {x:infoX, y:infoY});
				controlTween = TweenLite.to(imageLoader, 1.2, {alpha:0}); //fade interface elements
			}
		}
		
		protected function addEventHandler():void{
			stage.addEventListener(MouseEvent.CLICK, hideInfo); 
		}
		
		protected function removeEventHandler():void{
			stage.removeEventListener(MouseEvent.CLICK, hideInfo); 
			selectionMode = false; 
		}
		
		/*Return to default screen when any part of the screen is touched, excluding the sound scrubber*/
		protected function hideInfo(event:MouseEvent):void{
			if(event.target.name != "waveScrub"){
				returnToDefaultScreen();
		
			}
		
			
		}
		
		private function returnToDefaultScreen():void{
			windowTween.reverse();
			soundObjects[selectedSounds].HideInfo();
			
			/*remove soundwave*/
			removeChild(soundObjects[selectedSounds].wave);
			removeChild(soundObjects[selectedSounds].waveScrub);
			dotTween.reverse();
			controlTween.reverse();
			stage.removeEventListener(MouseEvent.CLICK, hideInfo);
			
			resumeSound();
			
			
		}
		
		private function timerListener (e:TimerEvent):void{
			timer.reset();
			timer.start();
			away3DScene.resetScene();
			if(selectionMode){
				returnToDefaultScreen();
			}
		}
		
		protected function resumeSound():void{
			for(var i:Number = 0; i < numCharacters; i++){
				soundObjects[i].resumeSound();
			}
		}
		
		protected function isolateSound(index:Number):void{
			for(var i:Number = 0; i < numCharacters; i++){
			
				if(i != index){
					
					soundObjects[i].quietSound();
					
				}
			}
		
		}
		
		
		/* Update panning, volume, and location of sound objects
		*/
		private function _onEnterFrame(e:Event):void
		{
			if(!selectionMode){
			updateSounds();
			} 
		}
		
		/*event handler for 2-finger zoom*/
		private function onZoom(e:TransformGestureEvent):void
		{
			var zoomOffset:Number = (1-e.scaleY)*20;
			away3DScene.setZoom(zoomOffset);
			currScale = e.scaleY;
		}
		
		/*event handler for two-finger swipe*/
		private function onSwipe(e:TransformGestureEvent):void
		{
			away3DScene.setPan(e);
		}
		
		/*event handler for two-finger pan*/
		private function onPan(e:TransformGestureEvent):void
		{
			var zoomOffset:Number = (1-e.scaleY)*80;
			away3DScene.setPan(e);
		}
		
		private function mouseDownHandler(e:MouseEvent):void{
			timer.reset();
			timer.start();
			
		}
		
		/*Update 3d position of objects and re-render on screen. 3d position is tracked by SoundSphere object for each sound*/
		private function updateSounds():void{
			
			for (var i:Number = 0; i < numCharacters; i++){
				var currChild:ObjectContainer3D = _skyBox.getChildAt(i);
				(currChild as SoundSphere).moveSphere();
				var _view:View3D = away3DScene.getView();
				var stage2dPos:Vector3D = _view.project(currChild.scenePosition);
				moveSoundObject(stage2dPos, i);
				
				
			}
		}
		
		/*Update 2-d position of soundObject to reflect 3d position of soundSphere*/
		private function moveSoundObject(stage2dPos:Vector3D, index:Number):void{
			
			if(stage2dPos.z > 0){
				soundObjects[index].visible = true;
			TweenMax.to(soundObjects[index], 0.01, {x:stage2dPos.x, y:stage2dPos.y, alpha:1});
			
			} else {
				/*hide objects that are not on the screen*/
				soundObjects[index].visible = false;
			}
		}
		
		
		
	}
	
	
}


