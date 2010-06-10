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
			var vizualizerHeight:uint = squareWidth*3;	// Height of the visualizer sprite.
			var x:int;									// x-coordinate of each vizualization bar.
			var h:int;									// height of each vizualization bar.

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
					x = (squareWidth/2) + ((i/samplesPerGroup)-1) * barWidth;
					h = -Math.floor(Math.abs(b * vizualizerHeight));
					g.drawRect(x,squareWidth*3,barWidth-5,h);
					top = 0;
				}
			//
			}
			g.endFill();
			
			return sprite;
		}
	}
}