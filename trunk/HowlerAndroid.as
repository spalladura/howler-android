package  {

	/**
	 *
	 * Howler MP3 Player for Android v1.0 
	 * Eric Carlisle
	 * http://www.ericcarlisle.com
	 * 
 	 * Copyright (c) 2010 Eric Carlisle
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software without
	 * restriction, including without limitation the rights to use,
	 * copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the
	 * Software is furnished to do so, subject to the following
	 * conditions:
	 *
	 * The above copyright notice and this permission notice shall be
	 * included in all copies or substantial portions of the Software.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	 * OTHER DEALINGS IN THE SOFTWARE.
	 *
	 * Special Thanks To:
	 * Gooogle - Droid Mono font from Google Font Directory - http://code.google.com/webfonts
	 *  
  	 */
	
	import com.ericcarlisle.howler.android.*;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.display.Screen;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
		
	public class HowlerAndroid extends MovieClip {
		
		
		private var file:File;													// File object for loading sound
		private var sound:Sound;												// Sound object
		private var channel:SoundChannel = new SoundChannel();					// Sound channel
		private var stransform:SoundTransform = new SoundTransform(1,0);		// Sound tranform
		private var song:Song = new Song();										// Sound metadata
		private var position:uint = 0;											// Sound position
		
		private var visualizer:Sprite;											// sprite to hold waveform visualizer.
		private var playMode:String = PlayModes.STOP;
		private var isScrubbing:Boolean = false;
		
		private var screenRect:Rectangle = Screen.mainScreen.visibleBounds;
		private var stageWidth:Number = screenRect.width;						// the stage's width
		private var stageHeight:Number = screenRect.height;						// the stage's height
		private var sqw:Number = stageWidth/6;									// width for wireframe grid square
		
		private var textFormat:TextFormat;										// textformat for txtID3

		/**
		 * Class constructor
		 */
		public function HowlerAndroid() 
		{						
			// Set stage properties.			
			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Create background sprite with wireframe grid.
			Vizualization.buildWireFrame(background,stageWidth,stageHeight,sqw);
			
			// Create visualizer sprite to contain graphics or spectrum waveform.
			visualizer = new Sprite();
			visualizer.x = 0; 
			visualizer.y = sqw * 1;
			addChild(visualizer);
						
			// Set text formatting for all textfields.
			textFormat = new TextFormat();
			textFormat.color = 0x00FF00;
			textFormat.leftMargin = 40;
			textFormat.rightMargin = 40;
			textFormat.size = 30;
			textFormat.font = DroidSans(new DroidSans()).fontName;
			
			txtID3.defaultTextFormat = textFormat;
			
			// Set position of stage elements based on screen orientation.
			positionStageElements();

			// Clear the visualizer.
			visualizer.graphics.clear(); // TODO: THIS DOESN'T WORK

			mcScrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberStartDrag);
			mcScrubber.addEventListener(MouseEvent.MOUSE_UP, scrubberStopDrag);
			
			// Attach event listeners to UI elements.
			btnOpen.addEventListener(MouseEvent.CLICK, openFile);
			btnExit.addEventListener(MouseEvent.CLICK, closeApplication);
			btnPause.addEventListener(MouseEvent.CLICK, pauseClick);
			btnPlay.addEventListener(MouseEvent.CLICK, playClick);

			// Attach event listeners for application activation and deactivation.
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,applicationDeactivate);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, applicationActivate);
			
			// Attach event listeners for device orientation change.
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange); 

			// Enter-frame events (updates the visualizer);
			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		/**
		 * Will change the x, y, and rotation for screen elements based on the device orientation.
		 */
		public function positionStageElements():void
		{
			if (stage.orientation == StageOrientation.ROTATED_RIGHT)
			{
				Vizualization.setAppearance(background,0,stageWidth,stageWidth,stageHeight,270);
				Vizualization.setAppearance(btnPlay,sqw*4,sqw*3,sqw,sqw,0);
				Vizualization.setAppearance(btnPause,sqw*4,sqw*3,sqw,sqw,0);
				Vizualization.setAppearance(btnExit,sqw*9,0,sqw,sqw,0);
				Vizualization.setAppearance(txtID3,0,sqw,sqw*10,sqw*2,0);
				Vizualization.setAppearance(visualizer,0,sqw,sqw*10,sqw*2,0);
				
				
				//background.rotation = 270;
				//background.y  = stageWidth;
				//btnPlay.y = sqw * 3;
				//btnPlay.x = sqw * 4;
				//btnPause.y = sqw * 3;
				//btnPause.x = sqw * 4;
				//btnExit.x = sqw * 9;
				//txtID3.y = sqw * 1;
				//txtID3.width = sqw * 10;
				//txtID3.height = sqw * 2;
				//visualizer.x = 0;
				//visualizer.y = sqw * 1;
			}
			else
			{
				Vizualization.setAppearance(background,0,0,stageWidth,stageHeight,0);
				Vizualization.setAppearance(btnPlay,sqw*2,sqw*7,sqw*2,sqw*2,0);
				Vizualization.setAppearance(btnPause,sqw*2,sqw*7,sqw*2,sqw*2,0);
				Vizualization.setAppearance(btnExit,sqw*5,0,sqw,sqw,0);
				Vizualization.setAppearance(txtID3,0,sqw,sqw*6,sqw*3,0);
				Vizualization.setAppearance(visualizer,0,sqw,sqw*6,sqw*3,0);

				//background.rotation = 0;
				//background.y = 0;
				//btnPause.x = sqw * 2;
				//btnPause.y = sqw * 7;
				//btnPlay.x = sqw * 2;
				//btnPlay.y = sqw * 7;
				//btnExit.x = sqw * 5;
				//txtID3.width = sqw * 6;
				//txtID3.height = sqw * 4;
				//txtID3.y = sqw * 1.5;
			}
			txtID3.htmlText = Vizualization.formatID3Data(song, stage.orientation);
		}

		/**
		 * Frame-specific logic.
		 */
		public function enterFrame(event:Event)
		{
			if (song.loaded)
			{
				visualizer.graphics.clear();
				Vizualization.BuildWaveForm(visualizer,sqw,stage.orientation);
			}
			
			if (playMode == PlayModes.PLAY && !isScrubbing)
			{
				var pos:uint = channel.position;
				mcScrubber.x = 10 + (pos/song.duration)*(stageWidth-mcScrubber.width-10);
			}
		}
		
		/**
		 * Handler for "open" button click event.
		 */
		public function openFile(event:Event):void
		{
			file = new File();
			file.browseForOpen("Open" ,[new FileFilter("MP3 Sound Files","*.mp3")]);
			file.addEventListener(Event.SELECT, soundSelected);
		}
	
		/**
		 * Handler for an mp3 file being selected.
		 */
		public function soundSelected(event:Event):void
		{
			txtID3.text = "Loading...";
			song.url = file.url;
			sound = new Sound(new URLRequest(file.url));
			sound.addEventListener(Event.ID3, loadID3Data);
			sound.addEventListener(Event.COMPLETE, soundLoaded);
		}
		
		/**
		 * Handler for loading on mp3 ID3 metadata.
		 */
		public function loadID3Data(event:Event):void
		{
			song.album = sound.id3.album;	
			song.artist = sound.id3.artist;	
			song.comment = sound.id3.comment;	
			song.genre = sound.id3.genre;	
			song.songName = sound.id3.songName;	
			song.track = sound.id3.track;	
			song.url = sound.id3.track;	
			song.year = sound.id3.year;	
		}

		/**
		 * Handler for loading of sound data.
		 */
		public function soundLoaded(event:Event):void
		{
			song.loaded = true;
			txtID3.htmlText = Vizualization.formatID3Data(song, stage.orientation);
			song.duration = sound.length;
			channel = sound.play(0,0,stransform);
			playMode = PlayModes.PLAY;
			btnPlay.visible = false;
		}
		
		/**
		 * Handler for play button click.
		 */
		public function playClick(event:Event):void
		{
			btnPlay.visible = false;
			channel = sound.play(position);
			playMode = PlayModes.PLAY;
		}

		/**
		 * Handler for pause button click.
		 */
		public function pauseClick(event:Event):void
		{
			btnPlay.visible = true;
			position = channel.position;
			channel.stop();
			playMode = PlayModes.STOP;
		}
		
		/**
		 * Handler for application deactivation.
		 */
		public function applicationDeactivate(event:Event):void
		{
			channel.stop();
			playMode = PlayModes.STOP;
		}

		/**
		 * Handler for application activation & reactivation.
		 */
		public function applicationActivate(event:Event):void
		{
			channel.stop();
			playMode = PlayModes.STOP;
		}

		/**
		 * Handler for exit button click.
		 */
		public function closeApplication(event:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * Handler for device orientation change.
		 */
		public function onOrientationChange(event:StageOrientationEvent)
		{
			positionStageElements();
		}
		
		/**
		 * Handler for scrubber mouse-down
		 */
		public function scrubberStartDrag(event:MouseEvent):void
		{
			isScrubbing = true;
			MovieClip(event.target).startDrag(false, new Rectangle(10,410,stageWidth-mcScrubber.width-20,0));
		}

		/**
		 * Handler for scrubber mouse-up
		 */
		public function scrubberStopDrag(event:MouseEvent):void
		{
			isScrubbing = false;
			channel.stop();
			channel = sound.play(song.duration *(mcScrubber.x/(stageWidth-mcScrubber.width-20)));
			MovieClip(event.target).stopDrag();
		}
	}
}
