(*
Move tasks from Things to OmniFocus
v1.0
Dov Frankel, 2013
*)

tell application "Things.app"
	set theArea to «class tsls» named "TV Shows"
	set theToDos to every «class tstk» in theArea
end tell

repeat with thingsToDo in theToDos
	tell application "Things.app"
		set theName to name of thingsToDo
		set theTags to «class tnam» of thingsToDo
	end tell
	
	tell application "OmniFocus"
		tell default document
			set TheProject to project "TV Shows" of folder "Lists"
			set TheContext to context "Mac" of context "Home"
			
			--display dialog "Name: " & theName & "
			--Tags: '" & theTags & "'"
			
			set newTask to make new inbox task with properties {name:theName, note:theTags, context:TheContext}
			set assigned container of newTask to TheProject
			
			compact
		end tell
	end tell
end repeat
