package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import com.greensock.TweenLite;
	
	public class Waveform extends Sprite
	{
		private var sound:Sound;
		private var soundWidth:Number;
		private var waveLoader:Loader;
		private var progress:Sprite;
	
		
		public function Waveform(sound_url:String, image_url:String, _width:Number)
		{
			/*sound = new Sound(); 
			soundWidth = _width;
			var waveformLeft:Sprite = new Sprite();
			sound.addEventListener(Event.COMPLETE, processSound); 
			//var req:URLRequest = new URLRequest("audio/imaRead.mp3"); 
			var req:URLRequest = new URLRequest(sound_url); 
			sound.load(req); */
			waveLoader = new Loader();
			var wave:URLRequest = new URLRequest(image_url);
			waveLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, placeImage);
			waveLoader.load(wave);
		}
		
		protected function placeImage(event:Event):void
		{	this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, waveLoader.width, waveLoader.height);
			progress = new Sprite();
			
			progress.graphics.beginFill(0xf15a29);
			//progress.graphics.beginFill(0xfbb040);
			progress.graphics.drawRect(0, 0, waveLoader.width, waveLoader.height);
			addChild(progress);
			this.blendMode = "layer";
			waveLoader.blendMode = 'erase';
			waveLoader.name = "wave";
			addChild(waveLoader);
		}
		public function update(pos:Number):void{
			progress.width = waveLoader.width*pos;
		}
	
		
		private function processSound(e:Event):void {
				
				var soundData:ByteArray = new ByteArray();
				
				// We need two sprites to draw the waveforms for the left and right channel
				var waveformLeft:Sprite = new Sprite();
				
				// We set a basic line style and reset the drawing position for each Sprite
				waveformLeft.graphics.moveTo(0,0);
				waveformLeft.graphics.lineStyle(2,0x000000);
				sound.extract(soundData,Math.floor((sound.length/1000)*44100));
				trace("sound length: "+sound.length);
				
				
				soundData.position = 0;
				var xStep:uint = 2;
				var avail:Number = soundData.bytesAvailable;
				var dataStep:Number = avail/(1920);
				trace("avail: "+ avail + "data step: "+dataStep);
				var xPos:uint = 0;
				
				var yRatio:uint = 400;
				trace("soundData bytes: "+soundData.bytesAvailable);
				while(soundData.bytesAvailable > 88200)
				{
					var leftMin:Number = Number.MAX_VALUE; // a variable to store the minimum value for the Left Channel
					var leftMax:Number = Number.MIN_VALUE; // a variable to store the maximum value for the Left Channel
					var rightMin:Number = Number.MAX_VALUE;// a variable to store the minimum value for the Right Channel
					var rightMax:Number = Number.MIN_VALUE; // a variable to store the maximum value for the Right Channel
					//trace("rightMax: "+rightMax);
					for (var i:uint = 0;i<2000;i++) // analyze every 11025 sample blocks and determine their
					//for (var i:uint = 0;i<dataStep;i++)
					{                               
						// read raw sound data for left channel (4 bytes/32 bits)
						var leftChannel:Number = soundData.readFloat();
						// read raw sound data for right channel (next 4 bytes/32 bits)
						var rightChannel:Number = soundData.readFloat();
						// 4 bytes + 4 bytes = 8 bytes = 1 sample block, remember? :)
						
						// check if we have a new minumum or maximum values for the left or right channels
						if (leftChannel < leftMin) leftMin = leftChannel;
						if (leftChannel > leftMax) leftMax = leftChannel;
						if (rightChannel < rightMin) rightMin = rightChannel;
						if (rightChannel > rightMax) rightMax = rightChannel;
					}
					// draw lines connecting the minimum and maximum values of the left and right channels
					// to their corresponding sprites.
					waveformLeft.graphics.lineTo(xPos,leftMin*yRatio);
					//waveformRight.graphics.lineTo(xPos,rightMin*yRatio);
					xPos += xStep;
					waveformLeft.graphics.lineTo(xPos,leftMax*yRatio);
					//waveformRight.graphics.lineTo(xPos,rightMax*yRatio);
					
					xPos += xStep;
				}
				
				// at this point the waveforms have been drawn to our left channel and right channel sprites.
				// it's time to position these sprites relative to the Stage and add them to the Stage as well.
				//waveformLeft.x = 0;
				waveformLeft.cacheAsBitmap;
				//waveformLeft.y = waveformLeft.height/2;
				addChild(waveformLeft);
				//waveformLeft.name = "wave";
				/*var b:BitmapData = new BitmapData(waveformLeft.width, waveformLeft.height, true, 0x0);
				b.draw(waveformLeft);
				var bitmap:Bitmap = new Bitmap(b);
				//addChild(bitmap);
				var bitContainer:Sprite = new Sprite();
				bitContainer.width = waveformLeft.width*2;
				bitContainer.height = waveformLeft.height;
				bitContainer.graphics.beginBitmapFill(b, null, true, true);
				bitContainer.y = 500;
				addChild(bitContainer);*/
				//var wavefromDouble:Sprite = 
				
				//waveforms[index] = bitContainer;
				//waveforms[index] = bitmap;
				//textContainer.addChild(waveformLeft);
				//waveformLeft.y = 150;
				//waveformRight.x = 0;
				//waveformRight.y = 150;
				//stage.addChild(waveformLeft);
				//return waveformLeft;
			
			//return waveformLeft;
		}
	}
}