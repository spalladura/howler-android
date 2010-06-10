package com.ericcarlisle.howler.android
{
	import flash.display.StageOrientation;
		
	public class Vizualization
	{
		/**
		 * Class Constructor
		 */
		public function Vizualization(){}

	
		public static function formatID3Data(song:Song, orientation:String):String
		{
			var formattedData:String;
			
			if (song.loaded)
			{
				trace(orientation);
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
	}
}