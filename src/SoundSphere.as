package
{

	import flash.geom.Vector3D;
	import away3d.containers.ObjectContainer3D;


	public class SoundSphere extends ObjectContainer3D
	{
		private var vel:Vector3D;
		private var acc:Vector3D;
		private var border:Number;
		public var angle:Number ; // The Initial Angle Orbiting Starts From
		public var speed:Number = 0.05; // Number Of Pixels Orbited Per Frame
		public var radius:Number = 750;
		//public var moveSphere:Object;
		public function SoundSphere(maxWidth:Number, zone:Number)
		{
			angle = Math.random() * 360;
			//maxWidth = 1;
			speed = Math.random()*0.2 - 0.1;
			border = 200;
			this.x = (Math.random() * (maxWidth*2))-maxWidth;
			this.z = (Math.random() * (maxWidth*2))-maxWidth;
			
			/*zone keeps certain species within a certain part of the screen if they are only found on the ground (zone 1), or the sky (zone 2)*/
			if(zone == 1){
				this.y =  (Math.random() * (400))-maxWidth;
			} else if (zone==2){
				this.y =  (Math.random() * (800))+maxWidth-800;
			} else {
				this.y =  (Math.random() *(maxWidth*(2/3)*2))-maxWidth*(2/3);
			}
			//this.y = (Math.random() * (maxWidth*2))-maxWidth;
			//vel = new Vector3D(2 - Math.random()*2, 2 - Math.random()*2, 2 - Math.random()*2);
			vel = new Vector3D(-Math.random()*2, Math.random()*2, Math.random()*2);
			acc = new Vector3D(Math.random()*2, Math.random()*2, Math.random()*2);
			trace("added!" + this.x);
			//addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			//_sphere.mouseEnabled = true;
			//trace("added DOT "+index);
		}
		
	
		
		public function moveSphere():void{
			//avoidWalls();
			//vel.x += acc.x;
			///vel.y += acc.y;
			//vel.z += acc.z;
			//this.x += vel.x;
			angle+=speed;
			//trace("acceleration: "+acc.x + "velocity: "+ vel.x + "location: " + this.x);
			//this.y += vel.y;
			//this.z += vel.z;
			var rad:Number = angle * (Math.PI / 180); // Converting Degrees To Radians
			this.x = radius * Math.cos(rad); // Position The Orbiter Along x-axis
			this.z = radius * Math.sin(rad); 
		}
		
		public function setSpeed(_speed):void{
			speed = _speed;
		}
		
		protected function avoidWalls():void
		{
			if((this.x > border)||(this.x < (border*(-1)))){
				
				acc.x*=(-1);
			}
			if((this.y > border)||(this.y < (border*(-1)))){
				acc.y*=(-1);
			}
			if((this.z > border)||(this.z < (border*(-1)))){
				acc.z*=(-1);
			}
		}
	}
}