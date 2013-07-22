package
{
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Track;
	import com.neriksworkshop.lib.ASaudio.core.IAudioItem;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	

	public class SoundObject extends Sprite
	{
		
		
		private var speciesInfo:SpeciesInfo;
		
		private var infoContainer:Sprite;
		private var soundTrack:Track;
		private var spectrum:Sprite;
		private var infoTween:TweenMax;
		private var soundTween:TweenMax;
		private var isolationMode:Boolean;
		public var wave:Waveform;
		private var volVal:Number;
		private var windowCenter:Point;
		public var waveScrub:Sprite;
		//private var material:ColorMaterial;
		
		public function SoundObject(_url:String, _desc:String, _index:Number, _species:String, soundGroup, _image:String, _windowCenter:Point, _waveurl:String, test:XML)
		{
			
			spectrum = new Sprite();
			spectrum.graphics.beginFill(0xcc6600, 0.6);
			spectrum.graphics.drawCircle(0, 0, 30);
			trace("SLKJHOEIPF " );
			//spectrum.width = 40;
			//spectrum.height = 40;
			spectrum.name = String(_index);
			addChild(spectrum);
			//this.name = String(_index);
			//this.addChild(spectrum);
			infoContainer = new Sprite();
			infoContainer.graphics.beginFill(0xFFFFFF);
			infoContainer.graphics.drawCircle(0, 0, 10);
			infoContainer.name = String(_index);
			addChild(infoContainer);
			isolationMode = false;
			windowCenter = _windowCenter;
			//this.width = 40;
			//this.height = 40;
			
			
			//trace(sound_url);
			//UNCOMMENT TO SHOW WAVEFORM
			wave = new Waveform(_url, _waveurl, 1920); 
			
			
			//var sound_url:String = soundList[i].@URL;
			soundTrack = new Track(_url, String(_index));
			
			soundGroup.addChild(soundTrack);
			
			soundTrack.start();
			soundTrack.volume = 0.6;
			soundTrack.loop = true;
			
			
			speciesInfo = new SpeciesInfo(_desc, _species,  _image);
			//speciesInfo.addChild(wave);
			trace("SOUND OBJECT: "+ soundTrack.name);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			speciesInfo.visible = false;
			//wave.mouseEnabled = false;
			
			waveScrub = new Sprite();
			waveScrub.graphics.beginFill(0xff0000, 0);
			waveScrub.graphics.drawRect(0, 0, 1920, 100);
			waveScrub.addEventListener(MouseEvent.CLICK, scrubSound);
			waveScrub.name = "waveScrub";
			//wave.addEventListener(MouseEvent.CLICK, scrubSound);
			//wave.blendMode = 'darken';
			//addChild(speciesInfo);
			
		}
		
		protected function scrubSound(event:MouseEvent):void
		{
			var newTime:Number = (stage.mouseX/wave.width);
			wave.update(newTime);
			soundTrack.start(false, newTime*soundTrack.duration, false);
			trace("scrubbed! " + stage.mouseX);
			// TODO Auto-generated method stub
			
		}
		
		public function ShowInfo(infoX:Number, infoY:Number, infoDiameter:Number):void{
			isolationMode = true;
			//TweenMax.to(this, 1, {x:infoX, y:infoY});
			trace("sound object width: " + this.width + "sound object x: " + this.x + "info x: "+ infoX + "info container Width: "+ infoContainer.width + " infoContainer x: " +infoContainer.x);
			infoTween= TweenMax.to(infoContainer, 1, {width: infoDiameter, height:infoDiameter, onComplete:showTitle});
			soundTween = TweenMax.to(soundTrack, 1, {volume:1});
			
		}
		
		public function HideInfo():void{
			if(contains(speciesInfo)){
			removeChild(speciesInfo);
			}
			//speciesInfo.visible = false;
			trace(infoTween);
			//if(infoTween!=null){
			//TweenMax.to(infoContainer, 1, {width: 40, height:40});
			infoTween.reverse();
			isolationMode = false;
			//}
		}
		
		public function quietSound():void{
			soundTween = TweenMax.to(soundTrack, 0.8, {volume:0});
			TweenMax.to(this, 1, {alpha: 0});
			isolationMode = true;
		}
		
		public function resumeSound():void{
			soundTween.reverse;
			//infoTween.reverse;
			TweenMax.to(this, 1, {alpha: 1});
			isolationMode = false;
		}
		
		
		protected function showTitle():void{
			//title_text.visible = true;
			speciesInfo.visible = true;
			addChild(speciesInfo);
			trace("sound object width: " + this.width + "sound object x: " + this.x + "info container Width: "+ infoContainer.width + " infoContainer x: " +infoContainer.x);
			//addChild(textContainer);
			//stage.addEventListener(MouseEvent.CLICK, HideInfo);
			//addChild(title_text);
		}
		
		protected function _onEnterFrame(event:Event):void
		{
			if(!isolationMode){
			transformSound();
			
			showSpectrum();
			} else {
				wave.update(soundTrack.position);
			}
		}
		
		protected function updateWave():void
		{
			//wave.update((soundTrack).position);
			//var scaleFactor:Number = 0.2+soundTrack.peak;
		//TweenMax.to(wave, 0.5, {scaleY:scaleFactor});
			////.x = -soundWave.width*();
//			//trace(wave);
			//trace((currTrack as Track).position);
			// TODO Auto Generated method stub
			
		}
		
		private function showSpectrum():void{
		var scaleFactor:Number = 1+soundTrack.peak*50;
		var newWidth:Number = soundTrack.peak*1000+20;
	 //   TweenMax.to(infoContainer, 0.2, {scaleX: 0.2+ volVal, scaleY:0.2+volVal});
		//TweenMax.to(this, 0.1, {x: this.x + scaleFactor});
		TweenMax.to(spectrum, 0.1, {scaleX:scaleFactor, scaleY:scaleFactor, colorMatrixFilter:{amount:4, saturation:scaleFactor-1}});
		}
		
		private function transformSound():void {
		
					//var volVal:Number = 0;
					var soundX:Number =  this.x - windowCenter.x;
					var soundY:Number =  this.y - windowCenter.y;
					var rad:Number = Math.sqrt(soundY*soundY+soundX*soundX);
					var panVal:Number = soundX/rad;
					volVal = 0.1-(rad-700)/700;
					//trace("volume: " + volVal);
			/*if (this.x > 20){
				if (this.y > 20){
					if (this.x < stage.width-20){
						if (this.y < stage.height-20){
							volVal = 0.6;
						}
									//trace(index+": "+leftX);
								
					}
					
					//}
					
				}	
			}*/
		//	if(volVal < 0) volVal = 0.01;
					if(volVal < 0) volVal = 0;
			TweenMax.to(soundTrack, 0.1, {pan: panVal, volume:volVal});
			/*currTrack.panTo(0.2, currTrack.pan, panVal, true);
			currTrack.volumeTo(0.2, currTrack.volume, volVal, true, null);*/
			
		}
		
	}
		
}