(*
Gruber Title
By Dov Frankel,
based on AppleScript by Cantus Vetustus, and Perl script by John Gruber & Aristotle Pagaltzis


Proper English Title Capitalization
By Cantus Vetustus
Report Bugs/Suggestions to cantusvetustus@spymac.com

Based on Doug Adams's original "Track Names to Word Caps" AppleScript.
His AppleScript can be downloaded at: http://www.malcolmadams.com/itunes/scripts/scripts09.shtml
*)


--===========LIST OF TAGS TO MODIFY===========--
--These are the tags that will be selected by default.
property my_tags_to_modify : {"name"}
--This is the list of tags you can modify.
property tags_to_modify : {"name", "artist", "composer", "album"}

property my_tags : my_tags_to_modify

on PerlCapitalize(theText)
	set command to "echo " & quoted form of theText & " | perl ~/Library/iTunes/Scripts/titlecase.pl"
	set capitalizedText to do shell script command
	return capitalizedText
end PerlCapitalize

tell application "iTunes"
	if selection is not {} then
		set old_fi to fixed indexing
		set fixed indexing to true
		copy selection as list to mySelectedTracks
		set songs_selected to (number of items in mySelectedTracks) as number
		if songs_selected = 1 then
			set songs_selected_message to "There is " & songs_selected & " track selected." as string
			set songs_modified_message to songs_selected & " track was modified." as string
		else
			set songs_selected_message to "There are " & songs_selected & " tracks selected." as string
			set songs_modified_message to songs_selected & " tracks were modified." as string
		end if
		
		set choice to button returned of (display dialog "Welcome to Gruber Title." & return & return & songs_selected_message buttons {"Cancel", "Configure…", "Modify"} default button 3 with icon 1)
		
		if choice = "Configure…" then
			set my_tags_to_modify to (choose from list tags_to_modify with prompt "Select the track tags you wish to modify (unselected tags will be ignored):" default items my_tags_to_modify with multiple selections allowed without empty selection allowed)
			if my_tags_to_modify is false then
				set my_tags_to_modify to my_tags
				run me
			else
				display dialog "Now we're ready." buttons {"Cancel", "Modify"} default button 2
			end if
		end if
		
		repeat with selected_tag in my_tags_to_modify --Check which tags are to be modified.
			repeat with aTrack in mySelectedTracks
				set selected_tag to selected_tag as string
				if selected_tag = "name" then set theTitle to aTrack's name
				if selected_tag = "artist" then set theTitle to aTrack's artist
				if selected_tag = "composer" then set theTitle to aTrack's composer
				if selected_tag = "album" then set theTitle to aTrack's album
				
				set newTitle to my PerlCapitalize(theTitle)
				
				if selected_tag = "name" then set aTrack's name to newTitle
				if selected_tag = "artist" then set aTrack's artist to newTitle
				if selected_tag = "composer" then set aTrack's composer to newTitle
				if selected_tag = "album" then set aTrack's album to newTitle
			end repeat
		end repeat
		
		copy old_fi to fixed indexing
		display dialog "Done!" & return & return & songs_modified_message buttons {"OK"} default button 1 with icon 1 giving up after 5
	else
		display dialog "There are no tracks selected." buttons {"Cancel"} default button 1 with icon 0
	end if
end tell


--Created by Doug Adams
--First Modified by Cantus Vetustus on Mon Jun 16, 2003
--Last Modified by Dov Frankel on Saturday Nov 14, 2009