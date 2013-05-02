(*
Load Torrent
v1.0
Dov Frankel, 2013
*)

property startWhenAdded : false
property targetGroup : "Test"

-- Use when testing script
--my hazelProcessFile(POSIX file "/Users/Dov/Downloads/SomeTorrentFile.torrent")

on hazelProcessFile(theFile)
	-- Open the Torrent file
	tell application "Transmission"
		activate
		open theFile
	end tell
	
	tell application "System Events"
		tell process "Transmission"
			-- Assumes Open Dialog is frontmost
			set openDialogWindow to window 1
			
			-- Is it set to start when added by default?
			set startChecked to (get value of checkbox "Start when added" of openDialogWindow) as boolean
			
			-- If app and script don't agree, toggle the checkbox
			if startChecked ­ startWhenAdded then
				click checkbox "Start when added" of openDialogWindow
			end if
			
			-- Change to the proper group
			set groupPopup to pop up button 2 of group 1 of openDialogWindow
			click groupPopup
			click menu item targetGroup of menu 1 of groupPopup
			
			--click button "Add" of openDialogWindow
		end tell
	end tell
end hazelProcessFile