(*
"Convert Script to Text"
by Dov Frankel
http://dovfrankel.com

Intended for use in an Automator service. Takes a selection of compiled AppleScript (.scpt) files, and converts them to plain-text applescript files (.applescript)

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

on run {input, parameters}
	
	repeat with inputFile in input
		tell application "AppleScript Editor"
			set doc to open inputFile
			copy doc to original_doc
			
			set newFileName to StringsLib's replace_text(POSIX path of inputFile, ".scpt", ".applescript")
			
			save doc as "text" in POSIX file newFileName
			close front window
		end tell
		
		tell application "Finder" to move inputFile to the trash
	end repeat
	
end run