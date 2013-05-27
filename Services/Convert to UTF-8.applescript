(*
Convert to UTF-8
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Takes a selection of text files, and uses BBEdit to convert them to UTF-8 format

*)

on run {input, parameters}
	
	repeat with inputFile in input
		tell application "BBEdit"
			set theDocument to open inputFile
			
			set encoding of theDocument to "Unicode (UTF-8)"
			save theDocument
			close theDocument
		end tell
	end repeat
	
end run