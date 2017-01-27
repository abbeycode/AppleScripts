(*
Receipt to Yojimbo
v1.0
Dov Frankel, 2017
http://dovfrankel.com
Hazel-triggered, saves a receipt PDF from Dropbox into Yojimbo, with appropriate naming and tagging
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property FilenamesLib : LibLoader's loadScript("Libraries:Filenames.applescript")
--property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
--property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

-- Use when testing script
my hazelProcessFile(POSIX file "/Users/Dov/Dropbox/Receipts/Amtrak - Reservations - Confirmation.pdf")

on hazelProcessFile(theFile)
	try
		-- Get the filename without ".pdf" at the end
		set filename to FilenamesLib's GetFileName(POSIX path of theFile)
		set filename to text 1 through character -5 of filename
		
		tell application "Yojimbo"
			set newItem to (import theFile)
			
			set the name of newItem to filename
			add tags {"Receipt", "Not In Quicken"} to newItem
		end tell
		
		tell application "Finder" to move theFile to the trash
	on error errorMessage
		tell GrowlLib to Notify("Error adding receipt to Yojimbo: " & errorMessage)
	end try
end hazelProcessFile