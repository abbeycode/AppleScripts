property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")
property OmniFocusLib : LibLoader's loadScript("Libraries:OmniFocus.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")

-- Get albums names from selected tracks
tell application "iTunes" to set {theAlbums} to {album} of selection

-- Get count of tracks
set albumCount to count theAlbums

-- Initialize master list
set allAlbumsList to {}

-- Remove duplicates
repeat with i from 1 to albumCount
	tell my theAlbums's item i to if it is not in my allAlbumsList and it ≠ "" then set end of my allAlbumsList to it
end repeat

-- Find start date, which should be the next Monday at 7:00 AM
(*
set theStartDate to DatesLib's timeofcurrentdate("7:00 am")
repeat while (theStartDate as string) does not start with "Monday"
	set theStartDate to theStartDate + 1 * days
end repeat
*)

-- Create tasks in OmniFocus
repeat with theAlbum in allAlbumsList
	set theTask to OmniFocusLib's CreateTask("Listen to '" & theAlbum & "'", "Regular Projects:Music", "Office")
	--tell application "OmniFocus" to set theTask's start date to theStartDate
end repeat

tell GrowlLib to NotifyNonsticky("Added tasks for " & (count of allAlbumsList) & " albums")