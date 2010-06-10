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
		public static function BuildWaveForm(sprite:Sprite, squareWidth:Number):Sprite
		{
			var bytes:ByteArray = new ByteArray();		// ByteArray containing spectrum data.
			var n:Number = 0;							// Sampled float of bytearray data.
			var top:int = 0;							// The highest byte value in a group.
			var samplesPerGroup:int = 63;				// Number of bytes in a group.
			var barWidth:int = 50;						// Width of rectangle that represents a group of bytes.
			var vizualizerHeight:uint = squareWidth*3;	// Height of the visualizer sprite.
			var x:int;

			// Place spectrum data in a bytearray.
			SoundMixer.computeSpectrum(bytes, false, 0);
			
			// Cleate new sprite and pointer to sprite graphics.
			var g = sprite.graphics;
			g.clear();
			
			// Set line and fill styles.
			g.lineStyle(1,0x00FF00,0.50);
			g.beginFill(0x00FF00, 0.25);
			
			for (var i:int = 0; i < 512; i++)
			{
				n = Math.floor(Math.abs(bytes.readFloat() * vizualizerHeight));
				if (i % samplesPerGroup != 0)
				{
					if (n > top) top = n;
				}
				else if (i != 0)
				{
					x = (squareWidth/2) + ((i/samplesPerGroup)-1) * barWidth;
					g.drawRect(x,squareWidth*3,barWidth-5,-top);
					top = 0;
				}
			}
			g.endFill();
			
			return sprite;
		}
	}
}