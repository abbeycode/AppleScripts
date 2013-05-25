(*
Library Loader
v1.0
Dov Frankel, 2013

loadScript() handler originally from http://codemunki.com


*** Instructions ***

Copy the compiled version (.scpt) into your ~/Library/Scripts directory, and then include it in your scripts like so:

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Library Loader.scpt")

You can load compiled scripts (.scpt) or plain text scripts (.applescript). Make sure, though, that your .applescript files are encoded as either Mac (what AppleScript Editor uses) UTF-8 (if you use another text editor). Any scripts loaded are expected to be installed into your Scripts directory. Use the line below to reference the script:

property LibName : LibLoader's loadScript("FolderName:SomeCoolScript.applescript")
*)

on loadScript(scriptRelativePath)
	
	set scriptFileToLoad to my fileAliasInScriptsFolder(scriptRelativePath) as text -- to be safe 
	try
		set scriptObject to load script alias scriptFileToLoad
	on error number -1752 -- text format script 
		set scriptText to ""
		try
			-- Try reading as Mac encoding first
			set scriptText to read alias scriptFileToLoad as text
		on error number -1700 -- Error reading script's encoding
			-- Finally try UTF-8
			set scriptText to read alias scriptFileToLoad as Çclass utf8È
		end try
		
		try
			set scriptObject to run script ("script s" & return & Â
				scriptText & Â
				return & "end script " & return & "return s")
		on error e number n partial result p from f to t
			display dialog Â
				"Error reading library 
" & scriptFileToLoad & "

" & e & "

Please encode as Mac or UTF-8"
			error e number n partial result p from f to t
		end try
	end try
	
	return scriptObject
end loadScript

on fileAliasInScriptsFolder(scriptRelativePath)
	return ((path to scripts folder from user domain as text) & scriptRelativePath) as alias
end fileAliasInScriptsFolder

-- Useful for testing this library
--property StringsLib : loadScript("Libraries:Strings utf16.applescript")