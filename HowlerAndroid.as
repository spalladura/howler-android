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
		
	public class HowlerAndroid extends MovieClip {
		
		private var file:File;													// File object for loading sound
		private var sound:Sound;												// Sound object
		private var channel:SoundChannel = new SoundChannel();					// Sound channel
		private var stransform:SoundTransform = new SoundTransform(1,0);		// Sound tranform
		private var song:Song = new Song();										// Sound metadata
		private var position:uint = 0;											// Sound position
		
		private var background:Sprite;											// Sprite for containing wireframe grid.
		private var visualizer:Sprite;											// sprite to hold waveform visualizer.

		private var btnPlay:PlayButton;											// play button control
		private var btnPause:PauseButton;										// pause button control
		private var btnOpen:OpenButton;											// button for opening file on fs
		private var btnExit:ExitButton;											// button for exiting application
		
		private var txtID3:TextField;											// test field to display ID3 metadata
		
		private var stageWidth:Number = stage.stageWidth;						// the stage's width
		private var stageHeight:Number = stage.stageHeight;						// the stage's height
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
			background = Vizualization.buildWireFrame(stageWidth,stageHeight,sqw);
			
			// Add wireframe grid to stage.
			this.addChild(background);
			
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
			textFormat.font = DroidMono(new DroidMono()).fontName;
			
			// Create UI elements.
			createButton(new PauseButton(), Buttons.PAUSE, sqw*2, sqw*2);
			createButton(new PlayButton(), Buttons.PLAY, sqw*2, sqw*2);
			createButton(new OpenButton(), Buttons.OPEN, sqw, sqw);
			createButton(new ExitButton(), Buttons.EXIT, sqw, sqw);
			createTextField(TextFields.ID3, sqw*6, sqw*4);
			
			// Create pointers to UI elements.
			btnOpen = OpenButton(this.getChildByName(Buttons.OPEN));
			btnExit = ExitButton(this.getChildByName(Buttons.EXIT));
			btnPause = PauseButton(this.getChildByName(Buttons.PAUSE));
			btnPlay = PlayButton(this.getChildByName(Buttons.PLAY));
			txtID3 = TextField(this.getChildByName(TextFields.ID3));

			// Set position of stage elements based on screen orientation.
			positionStageElements();
			
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

			this.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		/**
		 * Create buttons of specified type, instance name, width, and height.
		 */
		public function createButton(btn:DisplayObject, name:String, width:uint, height:uint):void
		{
			btn.x = x;
			btn.y = y;
			btn.width = width;
			btn.height = height;
			btn.name = name;
			addChild(btn);
		}
		
		/**
		 * Create text fields of specified width, height, and instance name.
		 */
		public function createTextField(name:String, width:uint, height:uint):void
		{
			var txt:TextField = new TextField();
			txt.width = width;
			txt.height = height;
			txt.name = name;
			txt.selectable = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.embedFonts = true;
			txt.defaultTextFormat = textFormat;
			addChild(txt);
		}

		/**
		 * Will change the x, y, and rotation for screen elements based on the device orientation.
		 */
		public function positionStageElements():void
		{
			if (stage.orientation == StageOrientation.ROTATED_RIGHT)
			{
				background.rotation = 270;
				background.y  = stageWidth;
				btnPlay.y = sqw * 3;
				btnPlay.x = sqw * 4;
				btnPause.y = sqw * 3;
				btnPause.x = sqw * 4;
				btnExit.x = sqw * 9;
				txtID3.y = sqw * 1;
				txtID3.width = sqw * 10;
				txtID3.height = sqw * 2;
				visualizer.x = 0;
				visualizer.y = sqw * 1;
			}
			else
			{
				background.rotation = 0;
				background.y = 0;
				btnPause.x = sqw * 2;
				btnPause.y = sqw * 7;
				btnPlay.x = sqw * 2;
				btnPlay.y = sqw * 7;
				btnExit.x = sqw * 5;
				txtID3.width = sqw * 6;
				txtID3.height = sqw * 4;
				txtID3.y = sqw * 1.5;
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
			channel = sound.play(position,0,stransform);
			btnPlay.visible = false;
		}
		
		/**
		 * Handler for play button click.
		 */
		public function playClick(event:Event):void
		{
			btnPlay.visible = false;
			channel = sound.play(position);
		}

		/**
		 * Handler for pause button click.
		 */
		public function pauseClick(event:Event):void
		{
			btnPlay.visible = true;
			position = channel.position;
			channel.stop();
		}
		
		/**
		 * Handler for application deactivation.
		 */
		public function applicationDeactivate(event:Event):void
		{
			channel.stop();
		}

		/**
		 * Handler for application activation & reactivation.
		 */
		public function applicationActivate(event:Event):void
		{
			channel.stop();
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
	}
}
