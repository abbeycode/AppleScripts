tell application "iTunes"
	if selection is not {} then
		copy selection as list to selectedTracks
		
		set old_fi to fixed indexing
		set fixed indexing to true
		
		repeat with theTrack in selectedTracks
			tell application "iTunes"
				set theTrack to first item of (tracks whose database ID = theTrack's database ID as integer)
				set theTrack's lyrics to "Instrumental"
			end tell
		end repeat
		
		copy old_fi to fixed indexing
	else -- Selection is empty
		display dialog "There are no tracks selected. Please select the tracks you wish to tag." buttons {"Cancel"} default button 1 with icon 0
		return "No tracks selected"
	end if
end tell
