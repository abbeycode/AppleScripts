(*
"Re-import Lossless Tracks"
Dov Frankel, 2013
http://dovfrankel.com

v1.0 March 9, 2013 (iTunes 11.0.2, Toast 11.0.3)

Requires iTunes and Toast Titanium

The Upgrade Tracks script has the side effect of leaving a track's Sound Check level the same as the original tracks, which can sometimes be a problem when upgrading, leaving a song playing back too loudly (or softly) with Sound Check enabled.

There's a way around it (for lossless files), but it involves using Toast, and specifically non-scriptable features of Toast. Because this script involves UI scripting, it cannot be called from the iTunes Script menu.

This automates the process of taking a lossless m4a iTunes track, burning it to a virtual audio CD, and then using iTunes's ability to re-import a song from its original CD, adjusts the volume level. You're ending up with a different file, but since it started out lossless* the resulting re-imported file should have the same audio data.


*You can use this script with lossy files, but it is not recommended, and the script will warn you if any non-lossless files are selected

*)

-- Initialize variables shared between applications
set originalPlaylist to {}
set originalSelection to {}
set fileAliases to {}
set albumTitle to ""
set trackInfo to {}
set discImagePath to ""
property originalEncoder : ""

-- Make sure UI scripting is enabled
tell application "System Events"
	if UI elements enabled is false then
		display dialog "This script requires that you enable 'UI Scripting' support for AppleScript. You will be prompted to authorize this change by the system. If you do not wish to authorize this, click Cancel."
		
		-- Automaticaly prompts the user
		set UI elements enabled to true
	end if
end tell

-- Pull out info from iTunes about selected tracks
tell application "iTunes"
	-- Save the original playlist and selection
	set originalPlaylist to view of front window
	set originalSelection to selection
	
	if selection is not {} then
		copy selection as list to selectedTracks
		
		set nonLosslessTracks to ""
		set nextTrackNumber to 1
		set trackCount to 0
		
		repeat with theTrack in selectedTracks
			tell application "iTunes"
				set theTrack to first item of (tracks whose database ID = theTrack's database ID as integer)
				
				-- Make sure the selection is complete, and sorted properly
				if theTrack's track number ≠ nextTrackNumber then
					display dialog "Please make sure the selection contains all of the album's tracks, sorted by track number. It looks like you skipped track " & nextTrackNumber & ".

Please correct the selection and try again." with icon 2 buttons {"OK"} default button 1
					return
				end if
				
				set nextTrackNumber to nextTrackNumber + 1
				
				-- Make a list of tracks whose files are not lossless
				if (theTrack's kind as text) does not contain "lossless" then
					set nonLosslessTracks to nonLosslessTracks & "
" & "\"" & theTrack's name & "\""
				end if
				
				-- Get the highest track count value from the selection
				if theTrack's track count > trackCount then set trackCount to theTrack's track count
				
				-- Fill two lists of track info to use later
				copy theTrack's location to the end of fileAliases
				copy {name:theTrack's name as text, albumName:theTrack's album as text} to the end of trackInfo
				
				if albumTitle = "" then set albumTitle to theTrack's album as text
			end tell
		end repeat
		
		-- Warn if any tracks are not lossless, give the opportunity to quit
		if nonLosslessTracks ≠ "" then
			display dialog "The following tracks are not lossless. Running this script may degrade their quality. Do you wish to continue?
" & nonLosslessTracks buttons {"Yes", "No"} default button 2 with icon 2
			if the button returned of the result is "No" then return
		end if
		
		-- If track count is specified, check that the number of tracks selected matches
		set highTrackNumber to nextTrackNumber - 1
		if trackCount > 0 and highTrackNumber ≠ trackCount then
			display dialog "This album looks like it should have " & trackCount & " tracks, but the highest selected track is number " & highTrackNumber & ". Do you wish to continue?" buttons {"Yes", "No"} default button 2 with icon 2
			if the button returned of the result is "No" then return
		end if
	else -- Selection is empty
		display dialog "There are no tracks selected. Please select the tracks you wish to re-import." buttons {"Cancel"} default button 1 with icon 0
		return "No tracks selected"
	end if
end tell

-- Create a file path for the disc image's location
tell application "Finder"
	set discImagePath to POSIX path of ((path to downloads folder as text) & albumTitle & ".Sd2f")
end tell

-- Check if the file already exists
set outputFileReference to null
set discImageFileExists to true
try
	set outputFileReference to POSIX file (discImagePath as text)
	tell application "Finder" to set discImageFileExists to exists outputFileReference
on error
	set discImageFileExists to false
end try

-- Burn and mount the virtual disc, only if it doesn't already exist
if not discImageFileExists then
	-- Create a new audio disc with the selected tracks' files
	tell application "Toast Titanium"
		activate
		set theDisc to make new Audio disc with properties {name:albumTitle}
		
		add to theDisc items fileAliases
	end tell
	
	-- Save the audio disc to a disc image using GUI scripting
	tell application "Toast Titanium" to activate
	tell application "System Events"
		tell process "Toast Titanium"
			click menu item "Save As Disc Image…" of menu "File" of menu bar 1
			set windowTitle to "Save Disc Image as:"
			repeat until exists window windowTitle
				delay 0.5
			end repeat
			
			tell window windowTitle
				keystroke "g" using {command down, shift down}
				repeat until exists sheet 1
					delay 0.5
				end repeat
				
				tell sheet 1
					-- Save clipboard
					set oldClipboard to the clipboard
					
					-- Copy/paste the path, instead of using 'keystroke' on the string, so it handles international characters correctly
					set the clipboard to discImagePath
					keystroke "a" using {command down}
					keystroke "v" using {command down}
					
					click button "Go"
					
					-- Restore the clipboard
					set the clipboard to oldClipboard
				end tell
				
				click button "Save"
			end tell
			
			repeat until exists UI element 21 of UI element 1 of UI element 2 of UI element 1 of UI element 7 of window "Toast 11 Titanium"
				delay 0.5
			end repeat
		end tell
	end tell
	
	
	-- Mount the disc image
	set outputFileReference to POSIX file (discImagePath as text)
	tell application "Toast Titanium" to mount image outputFileReference
	
	-- If multiple CDDB results are returned in iTunes, dismiss the dialog
	delay 5
	tell application "iTunes" to activate
	repeat 10 times
		tell application "System Events"
			tell process "iTunes"
				if exists window "CD Lookup Results" then
					click button "OK" of window "CD Lookup Results"
					exit repeat
				end if
			end tell
		end tell
		
		delay 0.5
	end repeat
end if -- If CD image file already exists

-- Import the tracks from the disc image
tell application "iTunes"
	set cdSource to null
	repeat while cdSource is null
		try
			set cdSource to first source whose kind is audio CD
		end try
	end repeat
	set discPlaylist to audio CD playlist 1 of cdSource
	set trackCount to count discPlaylist's tracks
	
	-- Make sure each tracks' info is correct. Specifically, artist, album, and track title need to match for each track number
	repeat with i from 1 to trackCount
		set discTrack to track i of discPlaylist
		set originalTrack to item i of originalSelection
		
		set tryCount to 0
		set tryFailed to true
		repeat until tryFailed = false
			try
				set album of discTrack to (album of originalTrack as text)
				set artist of discTrack to (artist of originalTrack as text)
				set name of discTrack to (name of originalTrack as text)
				set disc number of discTrack to (disc number of originalTrack as text)
				set disc count of discTrack to (disc count of originalTrack as text)
				set tryFailed to false
			on error message
				set tryCount to tryCount + 1
				if tryCount = 10 then
					display dialog "Failure to copy track info: " & message
					my cleanup()
					return
				end if
				
				set cdSource to (first source whose kind is audio CD)
				set discPlaylist to audio CD playlist 1 of cdSource
				set discTrack to track i of discPlaylist
				set originalTrack to item i of originalSelection
				delay 0.5
			end try
		end repeat
	end repeat
	
	-- Bring the CD "playlist" to front, in case it wasn't already
	activate
	set tryCount to 0
	set tryFailed to true
	repeat until tryFailed = false
		try
			set view of front browser window to discPlaylist
			set tryFailed to false
		on error message
			set tryCount to tryCount + 1
			if tryCount = 5 then
				display dialog "Failure to get to the virtual CD's playlist: " & message
				my cleanup()
				return
			end if
			
			delay 0.5
			set cdSource to first source whose kind is audio CD
			set discPlaylist to audio CD playlist 1 of cdSource
		end try
	end repeat
	
	-- Save encoder for putting it back later
	set originalEncoder to current encoder
	
	(* I'd loooove to allow the script to select only certain songs for importing, and have a lot of that code written below, but it doesn't look like (a) "convert" allows you to tell it to replace an existing file, and (b) "add" allows you to add a track from a CD to the library
	
	-- Have the user select which tracks to re-import
	set trackNamesToImport to (choose from list trackNameList with prompt "Select the track tags you wish to re-import (unselected tracks will be ignored):" default items trackNameList with multiple selections allowed without empty selection allowed)
	
	if trackNamesToImport is false then
		return
	end if
	
	try
		set newEncoder to some encoder whose name is "Lossless Encoder"
		set current encoder to newEncoder
		
		set tracksToImport to {}
		
		-- Make a list of the selected tracks
		repeat with i from 1 to trackCount
			set discTrack to track i of discPlaylist
			if trackNamesToImport contains discTrack's name then copy discTrack to the end of tracksToImport
		end repeat
		
		-- Import the tracks to a new playlist
		set importsPlaylist to (make new playlist with properties {name:albumTitle})
		
		repeat with trackToImport in tracksToImport
			log trackToImport's name as text
			log (location of trackToImport) as text
			add {location of trackToImport as alias} to importsPlaylist
		end repeat
		
		my cleanup()
	on error errStr number errorNumber
		log "Error!! : " & errStr
		my cleanup()
	end try
	*)
end tell

try
	-- Use iTunes GUI scripting to import the CD
	tell application "iTunes" to activate
	tell application "System Events"
		tell process "iTunes"
			click button "Import CD" of splitter group 1 of window "iTunes"
			
			set attemptCount to 15
			repeat until exists window "Import Settings"
				delay 0.5
				
				-- Don't try more than 15 times
				set attemptCount to attemptCount - 1
				if attemptCount = 0 then error "Unable to click 'Import CD' button"
			end repeat
			
			set importSettingsWindow to window "Import Settings"
			
			click pop up button 1 of importSettingsWindow
			
			set popupMenu to menu 1 of pop up button 1 of importSettingsWindow
			repeat with menuItem in menu items of popupMenu
				if (name of menuItem as text) = "Apple Lossless Encoder" then
					click menuItem
					exit repeat
				end if
			end repeat
			
			set errorCorrectionCheckbox to checkbox "Use error correction when reading Audio CDs" of importSettingsWindow
			
			if (get value of errorCorrectionCheckbox as boolean) then click errorCorrectionCheckbox
			
			click button "OK" of importSettingsWindow
			
			repeat until exists button "Replace Existing" of window 1
				delay 0.5
			end repeat
			click button "Replace Existing" of window 1
			
			delay 5
			repeat until (exists button "Import CD" of splitter group 1 of window "iTunes")
				delay 0.5
			end repeat
		end tell
	end tell
	
	my cleanup()
on error errStr number errorNumber
	log "Error!! : " & errStr
	my cleanup()
end try

-- Eject the disc
tell application "System Events"
	tell application "iTunes" to activate
	keystroke "e" using {command down}
end tell

-- Trash the CD image
tell application "Finder" to move outputFileReference to trash

-- Quit Toast
quit application "Toast Titanium" without saving

-- Finish up
tell application "iTunes"
	activate
	
	-- Go back to the original playlist with the same selection, or at least the first track
	set view of front window to originalPlaylist
	reveal first item of originalSelection
	
	display dialog "All done! Your tracks have been re-imported." with icon 1 buttons {"OK"} default button 1
end tell

on cleanup()
	if originalEncoder is not null then
		tell application "iTunes" to set current encoder to originalEncoder
	end if
end cleanup