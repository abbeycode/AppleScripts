(*
property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property iTunesLib : LibLoader's loadScript("Libraries:iTunes.applescript")
*)

--my SelectSource("Music")

(*
	tell iTunesLib to SelectSource("Music")
*)
-- Select an item in iTunes's sidebar with SourceName (can be a library, playlist, etc.)
on SelectSource(SourceName)
	set SourceName to SourceName as text
	
	tell application "iTunes" to activate
	
	tell application "System Events"
		tell process "iTunes"
			-- Loop through the various Scroll Areas in iTunes until we find the sources list
			repeat with i from 1 to 5
				try
					set libraryScrollArea to scroll area i of window "iTunes"
					set libraryList to outline 1 of libraryScrollArea
					
					if "sources" = description of libraryScrollArea as string then
						exit repeat
					end if
				end try
			end repeat
			
			repeat with libraryItem in every row of libraryList
				set theLabel to value of UI element 1 of libraryItem
				if theLabel is equal to SourceName then
					select libraryItem
					log ("Selected iTunes item '" & theLabel & "'")
					return true
				end if
			end repeat
		end tell
	end tell
	
	log ("Couldn't find iTunes item '" & SourceName & "'")
	return false
end SelectSource

(*
	set syncSuccess to iTunesLib's SyncAppleTv("Greedo")
*)
-- Syncs the specified AppleTV
-- Returns true if it was able to sync, false if it was already syncing or not available
on SyncAppleTv(AppleTvName)
	set AppleTvName to AppleTvName as text
	
	if not (my SelectSource(AppleTvName)) then
		log ("tv '" & AppleTvName & "' not found")
		return false
	end if
	
	tell application "iTunes" to activate
	
	tell application "System Events"
		tell process "iTunes"
			set syncMenuItem to menu item ("Sync “" & AppleTvName & "”") of menu 1 of menu bar item "File" of menu bar 1
			
			if syncMenuItem's enabled is true then
				log ("Syncing tv: " & AppleTvName)
				click syncMenuItem
				delay 5
				return true
			else
				log ("Not syncing tv: " & AppleTvName & " (already syncing)")
				return false
			end if
		end tell
	end tell
	
	return false
end SyncAppleTv
