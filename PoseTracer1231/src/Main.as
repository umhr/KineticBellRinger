package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author umhr
	 */
	[SWF(width = 1000, height = 480, backgroundColor = 0x333333, frameRate = 10)]
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.nativeWindow.visible = true;
			
			addChild(new Canvas());
			
			//var obj:Object = { head:"bbb", num:333 };
			//trace(obj.toString());
			//trace(JSON.stringify(obj));
		}
		
		
	}
	
}