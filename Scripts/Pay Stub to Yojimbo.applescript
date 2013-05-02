property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property FilenamesLib : LibLoader's loadScript("Libraries:Filenames.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

-- Use when testing script
--my hazelProcessFile(POSIX file "/Users/Dov/Dropbox/Briefcase/Pay Stub/2-29-2012.pdf")

on hazelProcessFile(theFile)
	try
		-- Get the filename without ".pdf" at the end
		set filename to FilenamesLib's GetFileName(POSIX path of theFile)
		set filename to text 1 through character -5 of filename
		
		-- Convert '-' to '/'
		set payStubDate to StringsLib's replace_text(filename, "-", "/")
		
		tell application "Yojimbo"
			set newItem to (import theFile)
			
			set the name of newItem to "Pay Stub " & payStubDate
			add tags {"Pay Stub"} to newItem
		end tell
		
		tell application "Finder" to move theFile to the trash
	on error errorMessage
		tell GrowlLib to Notify("Error adding pay stub to Yojimbo: " & errorMessage)
	end try
end hazelProcessFile
