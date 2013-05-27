(*
Rename Illustrator Exports
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Triggered by Hazel, it works around a limitation of Illustrator. This allows me to export a PNG copy of my Illustrator file without renaming it manually every time

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")

-- Use when testing script
--my hazelProcessFile(POSIX file "/Users/Dov/Source Code/SomeApp/Resources/Images/library-dark-01.png")

on hazelProcessFile(theFile)
	try
		set thePath to POSIX path of theFile
		
		set targetFileName to ((characters 1 through -10 of thePath) & ¬
			(characters -4 through -1 of thePath)) as text
		
		set command to "mv " & quoted form of thePath & " " & quoted form of targetFileName
		
		--log command
		do shell script command
		
	on error errorMessage
		tell GrowlLib to Notify("Error moving file: " & errorMessage)
	end try
end hazelProcessFile
