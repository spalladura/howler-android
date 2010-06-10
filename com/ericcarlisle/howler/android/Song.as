package com.ericcarlisle.howler.android
{
	import flash.media.Sound;
	
	public class Song
	{
		private var _album:String = "";
		private var _artist:String = "";
		private var _comment:String = "";
		private var _genre:String = "";
		private var _songName:String = "";
		private var _track:String = "";
		private var _year:String = "";
		private var _url:String = "";
		private var _duration:int;
		private var _loaded:Boolean = false;
		
		public function Song(){}

		public function get album():String { return _album; }; 
		public function set album(value:String):void { _album = value; }; 
		
		public function get artist():String { return _artist; }; 
		public function set artist(value:String):void { _artist = value; }; 
		
		public function get comment():String { return _comment; }; 
		public function set comment(value:String):void { _comment = value; }; 
		
		public function get genre():String { return _genre; }; 
		public function set genre(value:String):void { _genre = value; }; 
		
		public function get songName():String { return _songName; }; 
		public function set songName(value:String):void { _songName = value; }; 
		
		public function get track():String { return _track; }; 
		public function set track(value:String):void { _track = value; }; 
		
		public function get year():String { return _year; };
		public function set year(value:String):void { _year = value; }; 
		
		public function get url():String { return _url; };
		public function set url(value:String):void { _url = value; }; 
		
		public function get duration():int { return _duration; };
		public function set duration(value:int):void { _duration = value; }; 

		public function get loaded():Boolean { return _loaded; };
		public function set loaded(value:Boolean):void { _loaded = value; }; 
		
	}
}