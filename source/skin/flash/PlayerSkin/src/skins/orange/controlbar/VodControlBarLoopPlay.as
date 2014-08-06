/********************************************************************************
 * File        : ControlBar.as
 * Description : 点播播放器控制条
 --------------------------------------------------------------------------------
 * Author      : kevinlee
 * Date        : Apr 14, 2013 10:33:47 PM
 * Version     : 1.0
 * Copyright (c) 2013 the SEWISE inc. All rights reserved.
 ********************************************************************************/
package skins.orange.controlbar {
	import fl.controls.List;
	import fl.data.DataProvider;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import interfaces.player.IVodPlayerMediator;
	
	import skins.PlayerEvent;
	
	import utils.LanguageManager;
	import utils.Stringer;

	public class VodControlBarLoopPlay extends MovieClip {
		
		//控制条区背景
		public var controlBarBg:MovieClip;
		
		//播放进度条
		public var progressLine:ProgressLine;
		
		//暂停按钮
		public var pauseBtn:SimpleButton;
		
		//播放按钮
		public var playBtn:SimpleButton;
		
		//停止按钮
		public var stopBtn:SimpleButton;
		
		//播放时间
		public var playTime:TextField;
		
		//下载速度文本
		public var speedTf:TextField;
		
		//声音控制按钮
		public var soundCloseBtn:SimpleButton;

		//声音控制按钮
		public var soundOpenBtn:SimpleButton;
		
		//声音控制条
		public var volumeLine:VolumeLine;
		
		//清晰度按钮
		public var clarityBtn:SimpleButton;
		
		//全屏播放按钮
		public var fullBtn:SimpleButton;
		
		//正常屏幕按钮
		public var normalBtn:SimpleButton;
		
		//总时间字符串
		public var totalTime:String = "00:00:00";
		
		//设置清晰度事件
		public static const SHOW_CLARITY_SETTING:String = "show_clarity_setting";
		
		//jack fix///////////
		public var loopPlayState:Boolean = false;
		
		public function VodControlBarLoopPlay() {
			_orange = this.parent as VodOrangeLoopPlay;
			
			playBtn.visible = true;
			pauseBtn.visible = false;
			normalBtn.visible = false;
			soundOpenBtn.visible = false;
			
			speedTf.visible = false;
			
			/**
			 * 增加字幕控制按钮
			 * 2013.12.6 jackzhang
			 */
			subtitlesBtnBtn = subtitlesBtn.btn as SimpleButton;
			subtitlesBtnList = subtitlesBtn.list as List;
			subtitlesBtnBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			subtitlesBtnBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			//2013.12.6////////
			
			fullBtn.addEventListener(MouseEvent.CLICK, fullScreenHandler);
			fullBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			fullBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);

			normalBtn.addEventListener(MouseEvent.CLICK, noramlScreenHandler);
			normalBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			normalBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			
			playBtn.addEventListener(MouseEvent.CLICK, playHandler);
			playBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			playBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);

			pauseBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			pauseBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			pauseBtn.addEventListener(MouseEvent.CLICK, pauseHandler);

			stopBtn.addEventListener(MouseEvent.CLICK, stopHandler);
			stopBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			stopBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			
			soundCloseBtn.addEventListener(MouseEvent.CLICK, soundCloseHandler);
			soundCloseBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			soundCloseBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);

			soundOpenBtn.addEventListener(MouseEvent.CLICK, soundOpenHandler);
			soundOpenBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			soundOpenBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);

			volumeLine.addEventListener(VolumeLine.SOUND_OFF, soundOnHandler);
			volumeLine.addEventListener(VolumeLine.SOUND_ON, soundOffHandler);
			volumeLine.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			volumeLine.addEventListener(MouseEvent.MOUSE_MOVE, volumeTipHanlder);
			volumeLine.addEventListener(PlayerEvent.VOLUME_CHANGE, volumeHandler);

			clarityBtn.addEventListener(MouseEvent.MOUSE_OVER, tipShowHandler);
			clarityBtn.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);

			progressLine.addEventListener(MouseEvent.MOUSE_OUT, tipHideHanlder);
			progressLine.addEventListener(MouseEvent.MOUSE_MOVE, timeTipHanlder);
			progressLine.addEventListener(PlayerEvent.SEEK, seekHandler);
		}

/**------------------------------ 本对象大小及显示设置方法 ---------------------------*/
		
		public function resize(w:Number,h:Number):void{
			_curW = w;
			_curH = h;
			controlBarBg.width = w;
			
			//2013.12.6 jackzhang/////////////
			this.y = h - this.controlBarBg.height;
			//this.y = h - this.height;
			
			fullBtn.x = w - fullBtn.width - 20;
			normalBtn.x = fullBtn.x;
			
			/**
			 * 增加字幕控制按钮
			 * 2013.12.6 jackzhang
			 */
			var rightRefBtn:DisplayObject;
			if(subtitlesBtn.visible)
			{
				subtitlesBtn.x = normalBtn.x - subtitlesBtn.btn.width - 10;
				rightRefBtn = subtitlesBtn;
			}else{
				rightRefBtn = fullBtn;
			}
			//2013.12.6 jackzhang/////////////
			
			if(clarityBtn.visible)
			{
				clarityBtn.x = rightRefBtn.x - clarityBtn.width - 10;
				volumeLine.x = clarityBtn.x - volumeLine.width - 10;
			}else{
				volumeLine.x = rightRefBtn.x - volumeLine.width - 10;
			}
			
			soundCloseBtn.x = volumeLine.x - soundCloseBtn.width - 10;
			soundOpenBtn.x = soundCloseBtn.x;
			
			if(this.stage.displayState == StageDisplayState.FULL_SCREEN){
				fullBtn.visible = false;
				normalBtn.visible = true;
			}
			else{
				fullBtn.visible = true;
				normalBtn.visible = false;
			}
			show();
			progressLine.resize(w);
		}
		
		public function show():void{
			//2013.12.6 jackzhang/////////////
			var _showTween:Tween = new Tween(this, "y", Regular.easeOut, this.y, _orange.bg.height - this.controlBarBg.height, 0.5, true);
			//var _showTween:Tween = new Tween(this, "y", Regular.easeOut, this.y, _orange.bg.height - this.height, 0.5, true);
			_showTween.start();
		}
		
		public function hide():void{
			var _hideTween:Tween  = new Tween(this, "y", Regular.easeOut, this.y, _orange.bg.height, 1, true);
			_hideTween.start();
		}
		
/**------------------------------ 播放器视图代理调用的方法 ---------------------------*/
		
		public function setPlayer(p:IVodPlayerMediator):void{
			_player = p;
			//progressLine.setPlayer(p);
			//volumeLine.setPlayer(p);
		}
		
		public function setDuration(d:Number):void{
			_duration = d;
		}
		
		//播放时间字符串
		public function set playedTime(t:String):void{
			playTime.text = t + "/" + totalTime;
		}

		/**
		 * 设置下载速度显示
		 */
		public function setSpeed(speed:String):void{
			//speedTf.text = speed;
		}

		public function started():void{
			playBtn.visible = false;
			pauseBtn.visible = true;
			clarityBtn.enabled = true;
			//speedTf.visible = true;
			if(!clarityBtn.hasEventListener(MouseEvent.CLICK)) clarityBtn.addEventListener(MouseEvent.CLICK, clarityHandler);
			
			/**
			 * 增加字幕控制按钮
			 * 2013.12.6 jackzhang
			 */
			if(!subtitlesBtnBtn.hasEventListener(MouseEvent.CLICK)) subtitlesBtnBtn.addEventListener(MouseEvent.CLICK, subtitlesBtnBtnClickHandler);
			//2013.12.6 jackzhang/////////////
		}
		
		public function stopped():void{
			playBtn.visible = true;
			pauseBtn.visible = false;
			//speedTf.visible = false;
			playTimeReset();
			progressLine.stopped();
			if(clarityBtn.hasEventListener(MouseEvent.CLICK)) clarityBtn.removeEventListener(MouseEvent.CLICK, clarityHandler);
			
			/**
			 * 增加字幕控制按钮
			 * 2013.12.6 jackzhang
			 */
			if(subtitlesBtnBtn.hasEventListener(MouseEvent.CLICK)) subtitlesBtnBtn.removeEventListener(MouseEvent.CLICK, subtitlesBtnBtnClickHandler);
			//2013.12.6 jackzhang/////////////
		}
		
		public function paused():void{
			playBtn.visible = true;
			pauseBtn.visible = false;
		}
		
		private var stop_string:String;
		private var pause_string:String;
		private var play_string:String;
		private var fullScreen_string:String;
		private var normalScreen_string:String;
		private var soundOn_string:String;
		private var soundOff_string:String;
		private var clarity_string:String;
		
		//2013.12.6 jackzhang/////////////
		private var subtitles_string:String;
		public function initLanguage():void
		{
			stop_string = LanguageManager.getInstance().getString("stop");
			pause_string = LanguageManager.getInstance().getString("pause");
			play_string = LanguageManager.getInstance().getString("play");
			fullScreen_string = LanguageManager.getInstance().getString("fullScreen");
			normalScreen_string = LanguageManager.getInstance().getString("normalScreen");
			soundOn_string = LanguageManager.getInstance().getString("soundOn");
			soundOff_string = LanguageManager.getInstance().getString("soundOff");
			clarity_string = LanguageManager.getInstance().getString("clarity");
			
			//2013.12.6 jackzhang/////////////
			subtitles_string = LanguageManager.getInstance().getString("subtitles");
		}
		
		/**
		 * 增加字幕控制按钮
		 * 2013.12.6 jackzhang
		 */
		public var subtitlesBtn:MovieClip;
		private var subtitlesBtnBtn:SimpleButton;
		private var subtitlesBtnList:List;
		private var subtitlesListMaxRow:uint = 7;
		public function setSubtitlesLang(subtitlesLangArray:Array):void
		{
			subtitlesBtnList.dataProvider = new DataProvider(subtitlesLangArray);
			if(subtitlesBtnList.length < subtitlesListMaxRow)
			{
				subtitlesBtnList.height = subtitlesBtnList.length * subtitlesBtnList.rowHeight;
			}else{
				subtitlesBtnList.height = subtitlesListMaxRow * subtitlesBtnList.rowHeight;
			}
			subtitlesBtnList.y = - subtitlesBtnList.height - 19;
			subtitlesBtnList.selectedIndex = 1;
			//subtitlesBtnBtn.addEventListener(MouseEvent.CLICK, subtitlesBtnBtnClickHandler);
			subtitlesBtnList.addEventListener(Event.CHANGE, subtitlesBtnListChangeHandler);
		}
		private function subtitlesBtnListChangeHandler(e:Event):void
		{
			var selectObj:Object = subtitlesBtnList.selectedItem;
			_player.switchSubtitle(selectObj.data);
			subtitlesBtnList.visible = false;
		}
		private function subtitlesBtnBtnClickHandler(e:MouseEvent):void
		{
			if(subtitlesBtnList.visible)
			{
				subtitlesBtnList.visible = false;
			}else{
				subtitlesBtnList.visible = true;
			}
		}
		//2013.12.6 jackzhang/////////////
		
/**------------------------------ 私有属性及方法 ---------------------------*/

		//主播放器接口
		private var _player:IVodPlayerMediator;
		//顶级对象
		private var _orange:VodOrangeLoopPlay;
		//当前应用宽度
		private var _curW:Number;
		//当前应用高度
		private var _curH:Number;
		//本视图进度代表的时间长度
		private var _duration:Number;
		
		/**
		 * 全屏按钮事件响应
		 */
		private function fullScreenHandler(e:MouseEvent = null):void{
			this.stage.displayState = StageDisplayState.FULL_SCREEN;
			fullBtn.visible = false;
			normalBtn.visible = true;
		}

		/**
		 * 正常屏按钮事件响应
		 */
		private function noramlScreenHandler(e:MouseEvent = null):void{
			this.stage.displayState = StageDisplayState.NORMAL;
			fullBtn.visible = true;
			normalBtn.visible = false;
		}
		
		/**
		 * 全屏接口响应
		 */
		public function toFullScreen():void{
			//fullScreenHandler();
			//无法通过JS接口执行FLASH全屏操作，这里改为提示。
			var btnY:Number = this.y + playBtn.y -_orange.tipBubble.height - 3;
			_orange.tipBubble.showInfo(fullScreen_string, fullBtn.x + fullBtn.width/2, btnY, _orange.x, _curW);
			var myTimer:Timer = new Timer(2000, 1);
			myTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			myTimer.start();
			function timerHandler(event:TimerEvent):void{
				_orange.tipBubble.visible = false;
				myTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
				myTimer = null;
			}
		}
		public function toNoramlScreen():void{
			noramlScreenHandler();
		}
		
		/**
		 * 播放按钮事件响应
		 */
		private function playHandler(e:MouseEvent):void{
			//jack fix///////////
			loopPlayState = true;
			
			_player.play();
		}
		
		/**
		 * 暂停按钮事件响应
		 */
		private function pauseHandler(e:MouseEvent):void{
			//jack fix///////////
			loopPlayState = true;
			
			_player.pause();
		}

		/**
		 * 停止按钮响应
		 */
		private function stopHandler(e:MouseEvent):void{
			//jack fix///////////
			loopPlayState = false;
			
			_player.stop();
		}
		
		/**
		 * 播放时间重置
		 */
		private function playTimeReset():void{
			playTime.text = "00:00:00/00:00:00";
		}
		
		/**
		 * 声音关闭按钮事件响应
		 */
		private function soundCloseHandler(e:MouseEvent):void{
			soundCloseBtn.visible = false;
			soundOpenBtn.visible = true;
			_player.setVolume(0);
			volumeLine.close();
		}
		
		/**
		 * 声音打开按钮事件响应
		 */
		private function soundOpenHandler(e:MouseEvent):void{
			soundCloseBtn.visible = true;
			soundOpenBtn.visible = false;
			volumeLine.recover();
		}
		
		/**
		 * volumeLine发出的声音打开事件响应
		 */
		private function soundOnHandler(e:Event):void{
			soundCloseBtn.visible = false;
			soundOpenBtn.visible = true;
		}
		
		/**
		 * volumeLine发出的声音关闭事件响应
		 */
		private function soundOffHandler(e:Event):void{
			soundCloseBtn.visible = true;
			soundOpenBtn.visible = false;
		}
		
		/**
		 * 清晰度设置按钮事件响应
		 */
		private function clarityHandler(e:MouseEvent):void{
			dispatchEvent(new Event(SHOW_CLARITY_SETTING));
		}
		
		/**
		 * 各按钮的功能信息提示泡显示事件响应
		 */
		private function tipShowHandler(e:MouseEvent):void{
			var btnY:Number = this.y + playBtn.y -_orange.tipBubble.height - 3;
			
			switch(e.target){
				case clarityBtn:
					_orange.tipBubble.showInfo(clarity_string, clarityBtn.x + clarityBtn.width/2, btnY, _orange.x, _curW);
					break;
				case soundOpenBtn:
					_orange.tipBubble.showInfo(soundOn_string, soundOpenBtn.x + soundOpenBtn.width/2, btnY, _orange.x, _curW);
					break;
				case soundCloseBtn:
					_orange.tipBubble.showInfo(soundOff_string, soundCloseBtn.x + soundCloseBtn.width/2, btnY, _orange.x, _curW);
					break;
				case stopBtn:
					_orange.tipBubble.showInfo(stop_string, stopBtn.x + stopBtn.width/2, btnY, _orange.x, _curW);
					break;
				case pauseBtn:
					_orange.tipBubble.showInfo(pause_string, pauseBtn.x + pauseBtn.width/2, btnY, _orange.x, _curW);
					break;
				case playBtn:
					_orange.tipBubble.showInfo(play_string, playBtn.x + playBtn.width/2, btnY, _orange.x, _curW);
					break;
				case normalBtn:
					_orange.tipBubble.showInfo(normalScreen_string, normalBtn.x + normalBtn.width/2, btnY, _orange.x, _curW);
					break;
				case fullBtn:
					_orange.tipBubble.showInfo(fullScreen_string, fullBtn.x + fullBtn.width/2, btnY, _orange.x, _curW);
					break;
				
				/**
				 * 增加字幕控制按钮
				 * 2013.12.6 jackzhang
				 */
				case subtitlesBtnBtn:
					_orange.tipBubble.showInfo(subtitles_string, subtitlesBtn.x + subtitlesBtnBtn.width / 2, btnY, _orange.x, _curW);
					break;
				//2013.12.6 jackzhang/////////////
				
			}
		}
		
		/**
		 * 进度条时间提示泡事件响应
		 */
		private function timeTipHanlder(e:MouseEvent):void{
			var progressLineY:Number = this.y + progressLine.y -_orange.tipBubble.height - 2;
			
			var xTime:String = Stringer.secToString(_duration*(this.mouseX/_curW));
			
			_orange.tipBubble.showInfo(xTime, progressLine.mouseX, progressLineY, _orange.x, _curW);
		}
		
		/**
		 * 音量提示泡事件响应
		 */
		private function volumeTipHanlder(e:MouseEvent):void{
			var volumeLineY:Number = this.y + volumeLine.y -_orange.tipBubble.height - 2;
			_orange.tipBubble.showInfo(String(volumeLine.mouseX), progressLine.mouseX, volumeLineY, _orange.x, _curW);
		}
		
		/**
		 * 关闭提示泡事件响应
		 */
		private function tipHideHanlder(e:MouseEvent):void{
			_orange.tipBubble.visible = false;
		}
		
		private function seekHandler(e:Event):void{
			/**
			 * 当autoStart参数为false时，在直接执行seek操作后由于duration的值为NaN，
			 * 这将导致在皮肤层无法设置seekTime的值。为解决该问题已经在皮肤做处理，在此情况下
			 * 皮肤层直接将seekTime的值设置为seekPt，然后在这里再处理seekTime的值。
			 * 2013.9.16 jackzhang
			 */
			if(isNaN(_duration) || _duration == 0)
			{
				_player.seek(progressLine.seekPt);
			}else{
				_player.seek(progressLine.seekPt * _duration);
			}
			
			//MonsterDebugger.trace(this, "seekPt:" + progressLine.seekPt);
		}

		private function volumeHandler(e:Event):void{
			_player.setVolume(volumeLine.vol);
		}
		
	}
}
