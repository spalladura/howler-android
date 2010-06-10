package com.ericcarlisle.howler.android
{
	public class Utility
	{
		public static function formatDuration(duration:Number):String
		{
			var minutes:String = Math.floor(duration / 60000).toString();
			var seconds:String = Math.floor((duration % 60000) / 1000).toString();
			
			if (minutes.length == 1) minutes = "0" + minutes;
			if (seconds.length == 1) seconds = "0" + seconds;
			
			return minutes + ":" + seconds;
		}
		
		public static function getFileExtension(url:String):String
		{
			var arr:Array = url.split('.');
			var ext:String = arr[arr.length-1].toString().toLowerCase(); 			
			return ext;
		}
		
		public static function getFileName(url:String):String
		{
			var arr:Array = url.split('/');
			var filename:String = arr[arr.length-1].toString().toLowerCase(); 			
			return unescape(filename);
		}
	}
}