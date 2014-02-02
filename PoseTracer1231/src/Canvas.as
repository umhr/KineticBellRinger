package
{
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.bit101.components.CheckBox;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import jp.mztm.umhr.logging.Log;
    
    public class Canvas extends Sprite
    {
        
        private var kinect:Kinect;
        private var bmp:Bitmap;
		private var skeletonContainer:Sprite = new Sprite();
		private var _udpSccessor:UDPAccessor = UDPAccessor.getInstance();
		private var _poseData:PoseData = new PoseData();
		private var _checkBox:CheckBox;
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _minPushButton:PushButton;
		private var _middlePushButton:PushButton;
		private var _maxPushButton:PushButton;
		private var _fullScreenPushButton:PushButton;
		private var _randomPushButton:PushButton;
        public function Canvas()
        {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
            if(Kinect.isSupported())
            {
                bmp = new Bitmap();
                addChild(bmp);
                
                kinect = Kinect.getDevice();
                //kinect.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, kinect_depthImageUpdate);
                //kinect.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, kinect_depthImageUpdate);
                var settings:KinectSettings = new KinectSettings();
				//settings.depthEnabled = true;
				//settings.rgbEnabled = true;
				//settings.userMaskEnabled = true;
				settings.skeletonEnabled = true;
                kinect.start(settings);
				
				_checkBox = new CheckBox(this, 900, 8, "Message Sender");
				_checkBox.selected = true;
				
				addChild(skeletonContainer);
				addEventListener(Event.ENTER_FRAME, enterFrame);
				_udpSccessor.bind(7777);
            }
			
			_randomPushButton = new PushButton(this, 900, 8, "Random,", onRandom);
			_minPushButton = new PushButton(this, 900, 38, "0rh:0,0bd:0,0lh:0,", on0);
			_middlePushButton = new PushButton(this, 900, 68, "0rh:89,0bd:89,0lh:89,", on89);
			_maxPushButton = new PushButton(this, 900, 98, "0rh:179,0bd:179,0lh:179,", on179);
			_fullScreenPushButton = new PushButton(this, 900, 128, "FullScreen", onFullScreen);
			
			resize(null);
			addChild(new Log().fontSize(24));
			//addEventListener(Event.RESIZE, resize);
        }
		
		private function onFullScreen(e:Event):void 
		{
			if(stage.displayState == "normal"){
				stage.displayState = "fullScreen";
				_randomPushButton.visible = false;
				_minPushButton.visible = false;
				_middlePushButton.visible = false;
				_maxPushButton.visible = false;
				_fullScreenPushButton.visible = false;
				if(_checkBox){
					_checkBox.visible = false;
				}
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onFullScreen);
			}else{
				stage.displayState = "normal";
				_randomPushButton.visible = true;
				_minPushButton.visible = true;
				_middlePushButton.visible = true;
				_maxPushButton.visible = true;
				_fullScreenPushButton.visible = true;
				if(_checkBox){
					_checkBox.visible = true;
				}
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onFullScreen);
			}
			resize(null);
		}
		
		private function resize(e:Event):void 
		{
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;
		}
		
		private function onRandom(event:Event):void 
		{
			var ran0:int = Math.floor(Math.random() * 180);
			var ran1:int = Math.floor(Math.random() * 180);
			var ran2:int = Math.floor(Math.random() * 180);
			var message:String = "0rh:"+ran0+",0bd:"+ran1+",0lh:"+ran2+",1rh:"+ran0+",1bd:"+ran1+",1lh:"+ran2+",\n";
			UDPAccessor.getInstance().send(message, "192.168.0.255", 8989);
		}
		private function on0(event:Event):void 
		{
			var message:String = "0rh:0,0bd:0,0lh:0,1rh:0,1bd:0,1lh:0,\n";
			UDPAccessor.getInstance().send(message, "192.168.0.255", 8989);
		}
		private function on89(event:Event):void 
		{
			var message:String = "0rh:89,0bd:89,0lh:89,1rh:89,1bd:89,1lh:89,\n";
			UDPAccessor.getInstance().send(message, "192.168.0.255", 8989);
		}
		private function on179(event:Event):void 
		{
			var message:String = "0rh:179,0bd:179,0lh:179,1rh:179,1bd:179,1lh:179,\n";
			UDPAccessor.getInstance().send(message, "192.168.0.255", 8989);
		}
		
		private function kinect_usersMaskImageUpdate(event:UserEvent):void 
		{
		}
		
		private function enterFrame(e:Event):void 
		{
			skeletonContainer.graphics.clear();
			if (kinect.usersWithSkeleton.length == 0) {
				return;
			}
			var message:String = _poseData.setUsersWithSkeleton(kinect.usersWithSkeleton);
			
			if (_checkBox.selected) {
				UDPAccessor.getInstance().send(message, "192.168.0.255", 8989);
			}
			//return;
			
			//var object:Object = { };
			var count:int = 0;
			//var message:String = "";
			var s:String = "";
			var rgb:int = 0x00FF00;
			for each(var user:User in kinect.usersWithSkeleton) {
				//var obj:Object = { };
				//obj["id"] = user.trackingID;
				s = String(count);
				for each( var joint:SkeletonJoint in user.skeletonJoints) {
					rgb = 0x00FF00;
					if (joint.name == SkeletonJoint.RIGHT_HAND) {
						rgb = 0xFF0000;
						//obj[s + "lh"] = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.LEFT_HAND) {
						rgb = 0x0000FF;
						//obj[s + "rh"] = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.RIGHT_SHOULDER) {
						rgb = 0x990000;
						//obj[s + "rf"] = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.LEFT_SHOULDER) {
						rgb = 0x000099;
						//obj[s + "lf"] = joint.position.depth.y;
					}
					skeletonContainer.graphics.beginFill(rgb);
					skeletonContainer.graphics.drawCircle(joint.position.depth.x * (_stageWidth / 320), joint.position.depth.y * (_stageHeight / 240), 10);
					skeletonContainer.graphics.endFill();
				}
				//object[count] = obj;
				count ++;
			}
		}
		
		private function kinect_depthImageUpdate(event:CameraImageEvent):void 
		{
            bmp.bitmapData = event.imageData;
		}
    }
}
