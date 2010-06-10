package com.ericcarlisle.howler.android
{
	import flash.events.Event;
	
	
	[Bindable]
	public class PlayList extends Array
	{
		public var _index:uint = 0;
		
		public function set index(value:int):void 
		{ 
			this._index = value; 
			dispatchEvent(new Event(PlayerEvents.INDEX_CHANGE));
		}
		
		// Add a sound file to the playlist.
		public function addSong(song:Song):Boolean
		{
			// Boolean to check for duplicate list item.
			var isDuplicate:Boolean = false;
			var isValid:Boolean = true;
			
			// Only accept mp3 files (for this version).
			if (Utility.getFileExtension(song.url).toLowerCase() != "mp3")
			{
				isValid = false;
			}
			
			if (isValid)
			{
				// If ID3 tags are emtry, use filename for the title.
				if (song.songName == null || song.songName == "")
				{
					song.songName = song.url;
				}
				
				// Look through playlist.
				for (var i:int=0; i < this.length; i++)
				{
					
					// Check for duplicate 
					if (Song(this[i]).url == song.url)
					{
						isDuplicate = true;
					}
				}
				
				// If not a duplicate, add the item.
				if (!isDuplicate)
				{
					this.push(song);
				}
			}
			return isValid;
		}
		
		// Remove a sound file to the playlist.
		public function addSong(index:uint):void
		{
			this.splice(index,1);
		}
	}
}