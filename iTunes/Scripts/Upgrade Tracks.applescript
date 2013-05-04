(*
Upgrade Tracks
By Dov Frankel
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")



--===========LIST OF TAGS TO CLONE===========--
--These are the tags that will be selected by default
property my_tags_to_clone : {"Genre", "Comments", "Grouping"}
--This is the list of tags you can clone
property tags_to_clone : {"Name", "Artist", "Album Artist", "Year", "Track Number", "Disc Number", "Album", "Grouping", "Composer", "Comments", "Genre", "Compilation Flag", "Lyrics", "Artwork", "BPM"}

property jpgType : {".jpg", "JPEG"}
property pngType : {".png", "PNG"}

property copy_tags : false
property my_tags : my_tags_to_clone



------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------ Handlers ------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------


--Get the old track for the selected track
on FindOldTrack(TargetTrack)
	--Get list of artist matches and song name matches
	tell application "iTunes"
		set matchedTracks to tracks whose artist is (TargetTrack's artist as text) and name is (TargetTrack's name as text) and database ID is not (TargetTrack's database ID as integer)
	end tell
	
	--Filter artists to exact matches, and exclude the new song
	--set artistTracks to my FilterArtistList(artistTracks, TargetTrack, true)
	
	--If no artists are found, prompt the user for a different artist
	if matchedTracks = {} then
		set matchedTracks to my RequeryArtists(TargetTrack)
	end if
	
	set oldTrack to null
	
	--If exactly one match was found
	if number of items in matchedTracks = 1 then
		set oldTrack to (item 1 of matchedTracks)
		
		--Confirm deduction with user
		set songString to my DetailedSongString(oldTrack, false)
		tell application "iTunes"
			if (display dialog ("Substitute \"" & TargetTrack's name & "\"
for " & songString & "?") buttons {"No", "Yes"} default button "Yes" with icon 1)'s button returned = "No" then
				--Match was incorrect, requery
				set matchedTracks to my RequeryArtists(TargetTrack)
				set oldTrack to my PromptForOldTrack(matchedTracks, TargetTrack)
			end if
		end tell
	else --More than one match found
		set oldTrack to my PromptForOldTrack(matchedTracks, TargetTrack)
	end if
	
	return oldTrack
end FindOldTrack

--Filter artists to exact matches, and exclude the new song
on FilterArtistList(TrackList, ExcludedTrack, ExactMatchOnly)
	set resultList to {}
	
	tell application "iTunes"
		repeat with song in TrackList
			--If the song's artist is an exact match, or an exact match is not required, and the song is not the excluded song
			if (song's artist = ExcludedTrack's artist or not ExactMatchOnly) and song's database ID ­ ExcludedTrack's database ID then
				copy song to end of resultList
			end if
		end repeat
	end tell
	
	return resultList
end FilterArtistList

--If no matches are returned, keep prompting for a new search artist, searching with more imprecise results
on RequeryArtists(TargetTrack)
	set resultTracks to {}
	
	--As long as no matches are found
	repeat while resultTracks = {}
		tell application "iTunes"
			--Prompt for search string
			set dialogResult to display dialog "No artist matches found for \"" & TargetTrack's name & "\". Please specify the original track's artist." default answer (TargetTrack's artist as text)
			set artistSearchText to the text returned of dialogResult
			
			--Search for new search string
			set resultTracks to tracks whose artist contains artistSearchText
		end tell
		
		--Filter list to exclude the target track
		set resultTracks to my FilterArtistList(resultTracks, TargetTrack, false)
	end repeat
	
	return resultTracks
end RequeryArtists

--Multiple matches found, prompt user to specify which one is correct
on PromptForOldTrack(TrackList, TargetTrack)
	--Convert the list of iTunes tracks to a list of strings
	set songList to my TrackListToSongList(TrackList)
	set selectedTrack to null
	
	--Repeat as long as a track hasn't been selected
	repeat while selectedTrack = null
		tell application "iTunes"
			--Prompt for a song selection from the list
			set selectedTracks to choose from list songList with prompt "Select the original track for \"" & TargetTrack's name & "\" by " & TargetTrack's artist
		end tell
		
		--If the user cancelled
		if selectedTracks = false then
			tell application "iTunes"
				--Give the user a chance to specify a different artist
				set requery to display dialog "Would you like to specify a different artist?" buttons {"No", "Yes"} default button "Yes"
			end tell
			if requery's button returned = "Yes" then
				set TrackList to RequeryArtists(TargetTrack)
				set songList to TrackListToSongList(TrackList)
			else
				--Fail if they decide not to
				return null
			end if
		else if (number of items in selectedTracks) = 1 then
			set selectedTrack to first item of selectedTracks
		end if
	end repeat
	
	try
		set oldDelims to AppleScript's text item delimiters -- save their current state
		set AppleScript's text item delimiters to {"{", "}"} -- declare new delimiters
		
		--Get the database ID back out of the selected item
		set selectedDatabaseId to text item ((count of selectedTrack's text items) - 1) of selectedTrack as integer
		
		set selectedTrack to null
		
		tell application "iTunes"
			repeat with song in TrackList
				if song's database ID = selectedDatabaseId then
					set selectedTrack to song
					exit repeat
				end if
			end repeat
		end tell
		
		set AppleScript's text item delimiters to oldDelims -- restore them
	on error
		set AppleScript's text item delimiters to oldDelims -- restore them in case something went wrong
	end try
	
	return selectedTrack
end PromptForOldTrack

--Returns a list of strings that corresponds to a list of iTunes tracks
on TrackListToSongList(TrackList)
	set resultList to {}
	
	repeat with song in TrackList
		copy DetailedSongString(song, true) to end of resultList
	end repeat
	
	return resultList
end TrackListToSongList

--Returns a pretty-printed iTunes track, containing name, album, year, and date added, and optionally its iTunes database id
on DetailedSongString(SongTrack, AppendDatabaseId)
	tell application "iTunes"
		set dateAdded to DatesLib's formatDate(SongTrack's date added)
		set resultText to "\"" & SongTrack's name & "\" (" & SongTrack's album & ", " & SongTrack's year & ", added " & dateAdded & ")" as text
		
		if AppendDatabaseId then
			set resultText to resultText & " {" & SongTrack's database ID & "}" as text
		end if
		
		return resultText
	end tell
end DetailedSongString

on CloneTracks(SourceTrack, DestinationTrack)
	tell application "iTunes"
		set my_tags_to_clone to (choose from list tags_to_clone with prompt "Select the track tags you wish to clone (unselected tags will be ignored):" default items my_tags_to_clone with multiple selections allowed without empty selection allowed)
	end tell
	
	if my_tags_to_clone is false then
		set my_tags_to_clone to my_tags
		return false
	else
		repeat with tag in my_tags_to_clone --Check which tags are to be modified.
			--display dialog "dest: " & DetailedSongString(DestinationTrack, false) & "source: " & DetailedSongString(SourceTrack, false)
			set tag to tag as string
			
			tell application "iTunes"
				if tag = "name" then set DestinationTrack's name to (SourceTrack's name as text)
				if tag = "artist" then set DestinationTrack's artist to (SourceTrack's artist as text)
				if tag = "album artist" then set DestinationTrack's album artist to (SourceTrack's album artist as text)
				if tag = "year" then set DestinationTrack's year to (SourceTrack's year as integer)
				if tag = "track number" then
					set DestinationTrack's track number to (SourceTrack's track number as integer)
					set DestinationTrack's track count to (SourceTrack's track count as integer)
				end if
				if tag = "disc number" then
					set DestinationTrack's disc number to (SourceTrack's disc number as integer)
					set DestinationTrack's disc count to (SourceTrack's disc count as integer)
				end if
				if tag = "album" then set DestinationTrack's album to (SourceTrack's album as text)
				if tag = "grouping" then set DestinationTrack's grouping to (SourceTrack's grouping as text)
				if tag = "composer" then set DestinationTrack's composer to (SourceTrack's composer as text)
				if tag = "comments" then set DestinationTrack's comment to (SourceTrack's comment as text)
				if tag = "genre" then set DestinationTrack's genre to (SourceTrack's genre as text)
				if tag = "compilation" then set DestinationTrack's compilation to (SourceTrack's compilation as boolean)
				if tag = "lyrics" then set DestinationTrack's lyrics to (SourceTrack's lyrics as text)
				
				if tag = "artwork" then
					delete artworks of DestinationTrack
					
					set exportPath to (((path to desktop from user domain) as text) & "ExportedArt:") as text
					log exportPath
					do shell script "mkdir " & quoted form of POSIX path of exportPath
					
					set i to 1
					repeat with art in artworks of SourceTrack
						-- Export old artwork as a file
						set {ext, fileType} to pngType
						if my GetImageFormat(SourceTrack, i) contains "JPEG" then set {ext, fileType} to jpgType
						
						-- create pathToArtFile path -- really just a new individual name for the exported artwork
						set pathToArtFile to (exportPath & "exportedArt-" & i & ext) as text
						log pathToArtFile
						
						my exportRawDataToFile(SourceTrack, i, pathToArtFile, fileType)
						
						set data of artwork i of DestinationTrack to (read (file pathToArtFile) as picture)
						set i to i + 1
					end repeat
					
					do shell script "rm -r " & quoted form of POSIX path of exportPath
				end if
			end tell
		end repeat
		
		return true
	end if
end CloneTracks

-- From Doug's Re-Embed Artwork script
to GetImageFormat(theTrack, i)
	tell application "iTunes" to return (get format of artwork i of theTrack) as text
end GetImageFormat

-- From Doug's Re-Embed Artwork script
to exportRawDataToFile(theTrack, i, pathToNewFile, fileType)
	try
		tell me to set file_reference to (open for access pathToNewFile with write permission)
		tell application "iTunes" to write (get raw data of artwork i of theTrack) to file_reference starting at 0
		tell me to close access file_reference
		tell application "System Events" to set file type of (pathToNewFile as alias) to fileType
		return true
	on error m
		log m as text
		try
			tell me to close access file_reference
		end try
		return false
	end try
end exportRawDataToFile

on MergeSoundtrackInfo(SourceTrack, DestinationTrack)
	tell application "iTunes"
		if SourceTrack's grouping does not contain "Soundtrack" then return
		
		if DestinationTrack's grouping = "" then
			set DestinationTrack's grouping to "Soundtrack"
		else if DestinationTrack's grouping does not contain "Soundtrack" then
			set DestinationTrack's grouping to DestinationTrack's grouping & ", Soundtrack"
		end if
		
		if DestinationTrack's comment = "" then
			set DestinationTrack's comment to "In " & SourceTrack's album
		else if DestinationTrack's comment does not contain (SourceTrack's album as text) then
			set DestinationTrack's comment to DestinationTrack's comment & ", in " & SourceTrack's album
		end if
	end tell
end MergeSoundtrackInfo

on MergePlayCount(SourceTrack, DestinationTrack)
	tell application "iTunes" to set SourceTrack's played count to (SourceTrack's played count) + (DestinationTrack's played count)
end MergePlayCount


------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Script --------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Get the song selection, and quit if it's empty ---------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

tell application "iTunes"
	if selection is not {} then
		copy selection as list to selectedNewTracks
		set songs_selected to (number of items in selectedNewTracks) as number
		
		set old_fi to fixed indexing
		set fixed indexing to true
		copy selection as list to selectedNewTracks
	else -- Selection is empty
		display dialog "There are no tracks selected. Please select the new tracks you wish to replace." buttons {"Cancel"} default button 1 with icon 0
		return "No tracks selected"
	end if
end tell

------------------------------------------------------------------------------------------------------------------------------------
-------------------------------- Prompt whether to Replace, Clone & Replace, or Cancel ---------------------------------
------------------------------------------------------------------------------------------------------------------------------------

set prompt_message to "Replace older track with newer (selected) tracks?
			
Clone & Replace will copy the tags from the old songs onto the new songs."

tell application "iTunes"
	set choice to button returned of (display dialog prompt_message buttons {"Cancel", "Clone & Replace", "Replace"} default button 3 with icon 1)
	set cloneAndReplace to choice = "Clone & Replace"
end tell

------------------------------------------------------------------------------------------------------------------------------------
----------------------------- Loop through each song, performing the appropriate actions ------------------------------
------------------------------------------------------------------------------------------------------------------------------------

repeat with newTrack in selectedNewTracks
	--Set newTrack to the main library's copy so it gets deleted from the whole library later on
	tell application "iTunes" to set newTrack to first item of (tracks whose database ID = newTrack's database ID as integer)
	
	log "Finding old track"
	set oldTrack to my FindOldTrack(newTrack)
	log "Old track found"
	
	if oldTrack ­ null then
		------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------- If Clone, copy tags over ----------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------
		
		if cloneAndReplace then
			log "Starting Cloning"
			set clone_success to my CloneTracks(oldTrack, newTrack)
			
			if not clone_success then
				return "Clone Cancelled"
			end if
			
			log "Finished Cloning"
		end if
		
		------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------- Merge Soundtrack Info ----------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------
		
		log "Merging soundtrack info"
		my MergeSoundtrackInfo(oldTrack, newTrack)
		log "Soundtrack info merged"
		
		------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------- Merge Play Count -------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------
		
		log "Merging play count"
		my MergePlayCount(oldTrack, newTrack)
		log "Play count merged"
		
		------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------- Get old file's location and delete file --------------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------
		
		tell application "iTunes"
			set oldLocation to oldTrack's location
			set oldPath to POSIX path of (oldLocation as text)
			set oldDatabaseId to oldTrack's database ID as integer
			log "Deleting " & oldPath
			do shell script "rm -f " & quoted form of oldPath
			log "Old file deleted"
			
			------------------------------------------------------------------------------------------------------------------------------------
			------------------------------------ Store new file's location and remove from library -------------------------------------
			------------------------------------------------------------------------------------------------------------------------------------
			
			log "Removing " & newTrack's name & " from library"
			set newLocation to newTrack's location
			set newPath to POSIX path of (newLocation as text)
			delete newTrack
			log "New file removed"
			
			------------------------------------------------------------------------------------------------------------------------------------
			----------------------------------------------- Move new song to old location ------------------------------------------------
			------------------------------------------------------------------------------------------------------------------------------------
			
			try
				set oldDelims to AppleScript's text item delimiters -- save their current state
				set AppleScript's text item delimiters to {"."} -- declare new delimiters
				
				set newExtension to last text item of newPath
				set oldExtension to last text item of oldPath
				set oldPathNoExtension to text items 1 through ((count of oldPath's text items) - 1) of oldPath
				set oldPathNewExtension to (oldPathNoExtension as text) & "." & newExtension
				log "Moving " & newPath & return & "to" & return & oldPath
				do shell script "mv -f " & quoted form of newPath & " " & quoted form of oldPath
				log "New file moved"
				
				set AppleScript's text item delimiters to oldDelims -- restore them
			on error
				set AppleScript's text item delimiters to oldDelims -- restore them in case something went wrong
			end try
			
			------------------------------------------------------------------------------------------------------------------------------------
			---------------------------------------------- Play song to register new path ------------------------------------------------
			------------------------------------------------------------------------------------------------------------------------------------
			
			--set oldTrack to first item of (tracks whose database ID = (oldDatabaseId as integer))
			ignoring application responses
				--If the extensions haven't changed, then it will play uneventfully. If they have, it will link it to the file, but won't play
				try
					play oldTrack
				on error
					log "Error happened playing back old track before renaming extension. This is expected"
				end try
			end ignoring
			
			--If the new file's extension is different
			if newExtension ­ oldExtension then
				log "newExtension: " & newExtension & ", oldExtension: " & oldExtension
				log "Renaming " & oldPath & return & "to" & return & oldPathNewExtension
				--Rename the file back to its proper extension, now that iTunes is linked to its file ID
				do shell script "mv -f " & quoted form of oldPath & " " & quoted form of oldPathNewExtension
				log "New file's extension renamed"
				
				ignoring application responses
					--Now, make iTunes acknowledge the file and play it correctly
					play oldTrack
				end ignoring
			end if
			stop
		end tell
		
	else --oldTrack is null
		return "No track found"
	end if
end repeat

tell application "iTunes"
	copy old_fi to fixed indexing
	display dialog "Done!" buttons {"OK"} default button 1 with icon 1 giving up after 5
end tell

return "Finished execution"