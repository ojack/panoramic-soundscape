package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class SpeciesInfo extends Sprite
	{
		private var species:String;
		private var desc:String;
		private var soundMask:Sprite;
		private var imageLoader:Loader;
		
		public function SpeciesInfo(_desc:String,_species:String, _image:String) 
		{
			species = _species;
			desc = _desc;
			imageLoader = new Loader();
			var image:URLRequest = new URLRequest(_image);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, placeImage);
			imageLoader.load(image);
			//addChild (imageLoader);
			//imageLoader.width = 400;
		
			
			
			drawPopup();
			var soundMask:Sprite = new Sprite();
			//soundWave.mask = window;
			soundMask.graphics.beginFill(0x0FF000);
			soundMask.graphics.drawCircle(0, 0, 450);
			//addChild(soundMask);
			//_wave.y = -177;
			//addChild(_wave);
			//this.mask = soundMask;
			//_wave.mask = soundMask;
		}
		
		protected function placeImage(event:Event):void
		{
			trace("image loader width: "+-imageLoader.width);
			addChild(imageLoader);
			imageLoader.scaleX = 0.85
			imageLoader.scaleY = 0.85;
			imageLoader.x = -imageLoader.width;
			imageLoader.y = -200;
			
		}		
		
		
		private function drawPopup():void
		{
			
			
		
			var title_form:TextFormat = new TextFormat();
			title_form.size = 72;
			title_form.font = "BentonSansComp";
			//title_form.color = 0x777777;
			title_form.color = 0x444444;
			
			var title_text:TextField = new TextField();
			title_text.defaultTextFormat = title_form;
			title_text.embedFonts = true;
			//title_text.antiAliasType = AntiAliasType.ADVANCED;
			title_text.width = 800;
			title_text.height = 100;
			title_text.x = -30;
			title_text.y = -22;
			title_text.text = species;
			addChild(title_text);
			
			var desc_form:TextFormat = new TextFormat();
			desc_form.size = 18;
			
			desc_form.font = "BentonSansReg";
			var desc_text:TextField = new TextField();
			desc_text.defaultTextFormat = desc_form;
			desc_text.embedFonts = true;
			//desc_text.antiAliasType = AntiAliasType.ADVANCED;
			desc_text.text = desc;
			desc_text.wordWrap = true;
			desc_text.width = 400;
			desc_text.height = 600;
			
			//addChild(desc_text);
			desc_text.x = -22;
			desc_text.y = 100;
			
			
		}
	}
}