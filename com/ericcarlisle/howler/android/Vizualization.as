package com.ericcarlisle.howler.android
{
	import flash.display.StageOrientation;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.media.SoundMixer;
		
	public class Vizualization
	{
		/**
		 * Class Constructor
		 */
		public function Vizualization(){}

	
		/**
		 * Formats ID3 metadata based on device tilt. 
		 */
		public static function formatID3Data(song:Song, orientation:String):String
		{
			var formattedData:String;
			
			if (song.loaded)
			{
				if (orientation == StageOrientation.ROTATED_RIGHT)
				{
					formattedData = song.track + ". " + song.songName + "<br>" + song.artist + " - " + song.album + " (" + song.year + ") ";
				}
				else
				{
					formattedData = song.track + ". " + song.songName + "<br><br>" + song.album + " (" + song.year + ")<br><br>" + song.artist;
				}
			}
			else
			{
				formattedData = "";				
			}
			return formattedData;
		}

		/**
		 * Updates the waveform visualizer display. 
		 */
		public static function BuildWaveForm(sprite:Sprite, squareWidth:Number,  orientation:String):Sprite
		{
			var bytes:ByteArray = new ByteArray();		// ByteArray containing spectrum data.
			var b:Number = 0;							// Sampled float of bytearray data.
			var top:int = 0;							// The highest byte value in a group.
			var samplesPerGroup:int = 63;				// Number of bytes in a group.
			var barWidth:int = 50;						// Width of rectangle that represents a group of bytes.
			var vizualizerHeight:uint;					// Height of the visualizer sprite.
			var barX:int;								// x-coordinate of each vizualization bar.
			var y:int;									// y-coordinate for the entire visualization.
			var xMargin:int;							// Left margin for the waveform visualization. 
			var h:int;									// height of each vizualization bar.

			// Determine the left margin based on device orientation.
			if (orientation == StageOrientation.ROTATED_RIGHT)
			{
				xMargin = squareWidth*2
				barWidth = 70;
				y = squareWidth*2;
				vizualizerHeight = squareWidth*2;
			}
			else
			{
				xMargin = squareWidth * 0.5;
				barWidth = 50;
				y = squareWidth*3;
				vizualizerHeight = squareWidth*3;
			}
			
			// Place spectrum data in a bytearray.
			SoundMixer.computeSpectrum(bytes, false, 0);
			
			// Cleate new sprite and pointer to sprite graphics.
			var g = sprite.graphics;
			g.clear();
			
			// Set line and fill styles.
			g.lineStyle(1,0x00FF00,0.50);
			g.beginFill(0x00FF00, 0.25);
			
			// Iterate through all bytes.
			for (var i:int = 0; i < 512; i++)
			{
				// Find the current byte.
				b = bytes.readFloat();
				
				// For the batch of bytes in the group, keep the greatest byte for n.
				if (i % samplesPerGroup != 0)
				{
					if (b > top) top = b;
				}
				// For each group, draw a rectangle using n.
				else if (i != 0)
				{
					barX = xMargin + ((i/samplesPerGroup)-1) * barWidth;
					h = -Math.floor(Math.abs(b * vizualizerHeight));
					g.drawRect(barX,y,barWidth-5,h);
					top = 0;
				}
			//
			}
			g.endFill();
			
			return sprite;
		}
	}
}