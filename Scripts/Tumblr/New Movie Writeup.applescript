(*
Tumblr - New Movie Writeup
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Takes the selected text, and begins a dovfrankel.com Tumblr post for it, opening all the pages I use for those posts

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

property isDebugging : false

if not isDebugging then
	-- Copy current text to clipboard and use as default in dialog
	delay 0.5 -- give the user a chance to let go of an active keyboard shortcut
	tell application "System Events" to keystroke "c" using {command down}
	delay 0.1 -- so copy can take place
	set selected_text to (the clipboard as text)
	
	set default_answer to ""
	if selected_text ≠ "" then set default_answer to selected_text
	
	try
		set theResult to display dialog "Movie title?" default answer (default_answer as text)
	on error number -128 -- User Cancelled
		return
	end try
	set movieTitle to text returned of theResult
	
	set selectedTemplate to my selectTemplate()
	if selectedTemplate = false then return
else
	set movieTitle to "The Dark Knight"
	set selectedTemplate to "/Users/Dov/Library/Scripts/Tumblr/Templates/movie-writeup.xml"
end if

log "loading tumblr"
tell SafariLib to LoadUrlInNewWindow("http://www.tumblr.com/blog/dovfrankel/new/text?post[state]=1&redirect_to=%2Fblog%2Fdovfrankel%2Fdrafts")
log "loaded tumblr"

tell application "Safari"
	-- Escape the single quote, since it's used as a delimiter
	set movieTitle to StringsLib's replace_text(movieTitle, "'", "\\'")
	
	set titleToken to "<???>"
	set theUrls to {¬
		"http://www.imdb.com/find?q=" & titleToken & "&s=tt", ¬
		"http://www.amazon.com/s/url=search-alias%3Dmovies-tv&field-keywords=" & titleToken, ¬
		"http://www.themoviedb.org/search?search=" & titleToken ¬
		}
	
	-- Open other tabs
	repeat with theUrl in theUrls
		set newTab to (make new tab in front window)
		set encodedUrl to do JavaScript quoted form of theUrl & ".replace('" & titleToken & "', escape('" & movieTitle & "'))" in newTab
		set URL of newTab to encodedUrl
	end repeat
	
	set draftPage to front document
	
	-- Set post title
	do JavaScript "document.forms['edit_post']['post_one'].value = '" & movieTitle & " (____)'" in draftPage
	
	-- Get the values out of the template
	set templateContents to my getTemplateContents(selectedTemplate)
	
	-- Set the description from the template
	do JavaScript "document.forms['edit_post']['post_two'].value = " & quoted form of body of templateContents in draftPage
	
	-- Remove tags
	do JavaScript "
	while (link = document.getElementById('tokens').getElementsByTagName('a')[0]) {
		link.onclick();
	}" in draftPage
	
	-- Insert each tag from the template
	repeat with tag in tags of templateContents
		do JavaScript "insert_tag( " & quoted form of tag & ")" in draftPage
	end repeat
	
	-- Called after all tags are added/removed
	do JavaScript "tag_editor_update_form()" in draftPage
end tell

on selectTemplate()
	tell application "Finder"
		set templatesPath to ((get folder of (path to me)) as text) & "Templates"
		set filepaths to list folder templatesPath without invisibles
		
		if length of filepaths = 1 then
			set selectedTemplateFile to first item of filepaths
		else if length of filepaths = 0 then
			log "No templates present"
			selectedTemplateFile = false
		else
			set selectedTemplateFile to choose from list filepaths with prompt "Select the template you wish to use" default items (first item of filepaths)
		end if
		
		if selectedTemplateFile = false then return false
		
		set templatePath to (POSIX path of templatesPath) & "/" & selectedTemplateFile
		
		return templatePath
	end tell
end selectTemplate

on getTemplateContents(templateFileName)
	tell application "System Events"
		tell XML element "template" of contents of XML file templateFileName
			set theBody to value of XML element "body"
			set theTags to value of XML element "tags"
			
			set fixLinesScript to ¬
				"
import sys
for line in sys.stdin.readlines():
    sys.stdout.write(line.replace(\"\\n\", \"\\\\n\"))"
			
			set convertedBody to do shell script "echo " & quoted form of (theBody as Unicode text) & " | python -c '" & fixLinesScript & "'"
			set splitTags to StringsLib's split(",", theTags)
			
			return {body:convertedBody, tags:splitTags}
		end tell
	end tell
end getTemplateContents
