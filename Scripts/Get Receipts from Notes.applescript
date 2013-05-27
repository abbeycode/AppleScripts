(*
Get Receipts from Notes
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Looks through the Notes application for any notes starting with '$' and copies those subjects to the clipboard

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

tell application "Notes"
	activate
	delay 10
	
	set theResult to null
	
	repeat with theNote in every note
		
		if item 1 of (theNote's name as text) = "$" then
			if theResult is null then set theResult to "Notes Receipts:
"
			set theReceipt to DatesLib's formatDate(theNote's modification date) & ": " & theNote's name as text
			
			set theResult to theResult & theReceipt & "
"
		end if
		
	end repeat
	
	if theResult is null then
		set theResult to "No receipts found in Notes"
		quit
	end if
	
	return theResult
end tell
