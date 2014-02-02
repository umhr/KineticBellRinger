package  
{
	import com.as3nui.nativeExtensions.air.kinect.data.PointCloudRegion;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import flash.geom.Point;
	import jp.mztm.umhr.logging.Log;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class PoseData 
	{
		
		public function PoseData() 
		{
			
		}
		
		private var _lhMax0:Number = 0;
		private var _rhMax0:Number = 0;
		private var _lhMax1:Number = 0;
		private var _rhMax1:Number = 0;
		//private var _lsMax0:Number = 0;
		//private var _rsMax0:Number = 0;
		private var _bdMax:Number = 0;
		private var _lhMin0:Number = 1000;
		private var _rhMin0:Number = 1000;
		private var _lhMin1:Number = 1000;
		private var _rhMin1:Number = 1000;
		//private var _lsMin0:Number = 1000;
		//private var _rsMin0:Number = 1000;
		private var _bdMin:Number = 1000;
		private var _rh:int = 90;
		private var _bd:int = 90;
		private var _lh:int = 90;
		public function setUsersWithSkeleton(usersWithSkeleton:Vector.<User>):String {
			var count:int = 0;
			var message:String = "";
			var s:String = "";
			var lh:Number = 0;
			var bd:Number = 0;
			var rh:Number = 0;
			var rs:Number = 0;
			var ls:Number = 0;
			var rhY:Number = 0;
			var lhY:Number = 0;
			var rsY:Number = 0;
			var lsY:Number = 0;
			
			var n:int = usersWithSkeleton.length;
			
			if (n == 1) {
				// 一体検知した場合、首が画面の右半分にいる場合は1になるようにする。
				if (usersWithSkeleton[0].neck.position.depth.x > 160) {
					//trace("右", usersWithSkeleton[0].neck.position.depth.x);
					count = 1;
				}
			}else if (n > 1) {
				// 二体検知した場合、首の位置を確認し、左側を0に、右側を1になるようにする。
				if (usersWithSkeleton[0].neck.position.depth.x > usersWithSkeleton[1].neck.position.depth.x) {
					count = 1;
				}
			}
			
			
			for (var i:int = 0; i < n; i++) 
			{
				var user:User = usersWithSkeleton[i];
				
				s = String(count % 2);
				
				for each( var joint:SkeletonJoint in user.skeletonJoints) {
					if (joint.name == SkeletonJoint.RIGHT_HAND) {
						rh = (count % 2 == 0)?joint.position.depth.y:joint.position.depth.x;
						rhY  = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.NECK) {
						bd = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.LEFT_HAND) {
						lh = (count % 2 == 0)?joint.position.depth.y:joint.position.depth.x;
						lhY = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.RIGHT_SHOULDER) {
						rs = (count % 2 == 0)?joint.position.depth.y:joint.position.depth.x;
						rsY = joint.position.depth.y;
					}else if (joint.name == SkeletonJoint.LEFT_SHOULDER) {
						ls = (count % 2 == 0)?joint.position.depth.y:joint.position.depth.x;
						lsY = joint.position.depth.y;
					}
				}
				
				if (count % 2 == 0) {
					_rhMax0 = Math.max(rh, _rhMax0);
					_lhMax0 = Math.max(lh, _lhMax0);
					_rhMin0 = Math.min(rh, _rhMin0);
					_lhMin0 = Math.min(lh, _lhMin0);
				}else {
					_rhMax1 = Math.max(rh, _rhMax1);
					_lhMax1 = Math.max(lh, _lhMax1);
					_rhMin1 = Math.min(rh, _rhMin1);
					_lhMin1 = Math.min(lh, _lhMin1);
				}
				_bdMax = Math.max(bd, _bdMax);
				_bdMin = Math.min(bd, _bdMin);
				
				if (count % 2 == 0) {
					var rhtemp:int = map(rs, rh, _rhMin0, _rhMax0);
					var bdtemp:int = headMap((_bdMax + _bdMin) * 0.5, bd, _bdMin, _bdMax);
					var lhtemp:int = map(ls, lh, _lhMin0, _lhMax0);
					
					if (rhtemp - bdtemp> 60) {
						rhtemp -= (rhtemp - bdtemp - 60) * 0.7;
						rhtemp = Math.max(rhtemp, 0);
					}
					if (lhtemp - bdtemp> 60) {
						lhtemp -= (lhtemp - bdtemp - 60) * 0.7;
						lhtemp = Math.max(lhtemp, 0);
					}
					
					message += s + "rh:" + rhtemp + ",";
					message += s + "bd:" + bdtemp + ",";
					message += s + "lh:" + lhtemp + ",";
				}else {
					// 右側、鐘つき側
					if(rhY <= rsY || lhY <= lsY){
						_rh = map(rs, rh, _rhMin1, _rhMax1);
						_bd = map((_bdMax + _bdMin) * 0.5, bd, _bdMin, _bdMax);
						_lh = map(ls, lh, _lhMin1, _lhMax1);
					}
					message += s + "rh:" + _rh + ",";
					message += s + "bd:" + _bd + ",";
					message += s + "lh:" + _lh + ",";
				}
				count ++;
			}
			
			if (Math.random() > 0.99) {
				_rhMax0 = _rhMax0 * 0.9 + rh * 0.1;
				_lhMax0 = _lhMax0 * 0.9 + lh * 0.1;
				_rhMax1 = _rhMax1 * 0.9 + rh * 0.1;
				_lhMax1 = _lhMax1 * 0.9 + lh * 0.1;
				_bdMax = _bdMax * 0.9 + bd * 0.1;
				_rhMin0 = _rhMin0 * 0.9 + rh * 0.1;
				_lhMin0 = _lhMin0 * 0.9 + lh * 0.1;
				_rhMin1 = _rhMin1 * 0.9 + rh * 0.1;
				_lhMin1 = _lhMin1 * 0.9 + lh * 0.1;
				_bdMin = _bdMin * 0.9 + bd * 0.1;
			}
			
			message += "\n";
			return message;
		}
		
		private function headMap(center:Number, value:Number, low:Number, high:Number):Number {
			var num:Number = value-center;
			if (num < 0) {
				num = -(num / (low - center)) * 60 + 90;
			}else {
				num = (num / (high - center)) * 60 + 90;
			}
			if (isNaN(num)) {
				num = (num < 0)?0:180;
			}
			return Math.floor(Math.min(150, Math.max(30, num)));
		}
		private function map(center:Number, value:Number, low:Number, high:Number):Number {
			var num:Number = value-center;
			if (num < 0) {
				num = -(num / (low - center)) * 90 + 90;
			}else {
				num = (num / (high - center)) * 90 + 90;
			}
			if (isNaN(num)) {
				num = (num < 0)?0:180;
			}
			return Math.floor(Math.min(180, Math.max(0, num)));
			//return Math.floor(Math.min(170, Math.max(10, num)));
		}
		
		private function minmax(num:Number):int {
			return Math.floor(Math.min(180, Math.max(0, num)));
		}
		
		public function clone():PoseData {
			var result:PoseData = new PoseData();
			
			return result;
		}
		
		public function toString():String {
			var result:String = "PoseData:{";
			
			result += "}";
			return result;
		}
		
	}
	
}