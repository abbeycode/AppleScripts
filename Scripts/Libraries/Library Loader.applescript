(*
Library Loader
v1.0
Dov Frankel, 2013

Original loadScript() handler from http://codemunki.com


*** Instructions ***

Copy into your ~/Library/Scripts directory, and then include it in your scripts like so:

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Library Loader.scpt")

You can load compiled scripts (.scpt) or plain text scripts (.applescript). Make sure, though, that your .applescript files are encoded at UTF-8. Any scripts loaded are expected to be installed into your Scripts directory. Use the line below to reference the script:

property LibName : LibLoader's loadScript("FolderName:SomeCoolScript.applescript")
*)

on loadScript(scriptRelativePath)
	
	set scriptFileToLoad to my fileAliasInScriptsFolder(scriptRelativePath) as text -- to be safe 
	try
		set scriptObject to load script alias scriptFileToLoad
	on error number -1752 -- text format script 
		set scriptObject to run script ("script s" & return & ¬
			(read alias scriptFileToLoad as «class utf8») & ¬
			return & "end script " & return & "return s")
	end try
	
	return scriptObject
end loadScript

on fileAliasInScriptsFolder(scriptRelativePath)
	return ((path to scripts folder from user domain as text) & scriptRelativePath) as alias
end fileAliasInScriptsFolder