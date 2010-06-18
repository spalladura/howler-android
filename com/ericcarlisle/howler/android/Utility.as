package com.ericcarlisle.howler.android
{
	public class Utility
	{
		public static function formatDuration(duration:Number):String
		{
			var formattedDuration:String = "";
			
			var hours:String = Math.floor(duration / 3600000).toString();
			var minutes:String = Math.floor(duration / 60000).toString();
			var seconds:String = Math.floor((duration % 60000) / 1000).toString();
			
			if (hours.length == 1) minutes = "0" + minutes;
			if (minutes.length == 1) minutes = "0" + minutes;
			if (seconds.length == 1) seconds = "0" + seconds;
			
			if (int(hours) > 0)
			{
				formattedDuration = hours + ":" + minutes + ":" + seconds
			}
			else
			{
				formattedDuration = minutes + ":" + seconds
			}
			
			return formattedDuration;
		}
	}
}