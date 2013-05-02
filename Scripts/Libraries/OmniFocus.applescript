(*
OmniFocus Library
v1.0
Dov Frankel, 2013


property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property OmniFocusLib : LibLoader's loadScript("Libraries:OmniFocus.applescript")
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

-- Creates a task in the specified Project and Context (colon-separated paths)
(*
tell OmniFocusLib to CreateTask( "Test", "Miscellaneous", "Home" )
*)
on CreateTask(TaskName, ProjectName, ContextName)
	tell application "OmniFocus"
		tell default document
			set TheProject to my ProjectWithPath(ProjectName)
			set TheContext to my ContextWithPath(ContextName)
			
			-- Create the new Task, assigning all properties except Project
			set newTask to make new inbox task with properties ¬
				{name:TaskName, context:TheContext}
			
			-- Assign Project to new Task
			set assigned container of newTask to TheProject
			
			-- Cleans up all entered data
			compact
			
			return newTask
		end tell
	end tell
end CreateTask

-- Returns the project at the specified colon-separated path
(*
OmniFocusLib's ProjectWithPath( "Apps:Sick Day" )
*)
on ProjectWithPath(ProjectPath)
	tell application "OmniFocus"
		tell default document
			if (class of ProjectPath is task) or (class of ProjectPath is project) then return ProjectPath
			
			-- Optimize for simplest case
			if ProjectPath does not contain ":" then ¬
				return project (ProjectPath as string)
			
			-- Split path into constituent parts
			set pathParts to StringsLib's split(":", ProjectPath)
			
			-- This will act as a reference to the OF object one level up
			set theParent to null
			
			-- Repeat with each part of the path
			repeat with pathPart in pathParts
				
				-- If thePart has a parent, use it
				if theParent is not null then
					try
						set thePart to folder pathPart of theParent
					on error
						try
							set thePart to project pathPart of theParent
						on error
							set thePart to task pathPart of theParent
						end try
					end try
				else
					-- There is no parent, so this must be the root folder
					set thePart to folder pathPart
				end if
				
				-- The part this time through is the parent next time through
				set theParent to thePart
			end repeat
			
			-- The last part found is the project we're looking for
			return thePart
		end tell
	end tell
end ProjectWithPath


-- Returns the context at the specified colon-separated path
(*
OmniFocusLib's ContextWithPath( "Apps:Sick Day" )
*)
on ContextWithPath(ContextPath)
	tell application "OmniFocus"
		tell default document
			-- Optimize for simplest case
			if ContextPath does not contain ":" then ¬
				return context (ContextPath as string)
			
			-- Split path into constituent parts
			set pathParts to StringsLib's split(":", ContextPath)
			
			-- This will act as a reference to the OF object one level up
			set theParent to null
			
			-- Repeat with each part of the path
			repeat with pathPart in pathParts
				
				-- If thePart has a parent, use it
				if theParent is not null then
					set thePart to context pathPart of theParent
				else
					-- There is no parent, so this must be the root context
					set thePart to context pathPart
				end if
				
				-- The part this time through is the parent next time through
				set theParent to thePart
			end repeat
			
			-- The last part found is the project we're looking for
			return thePart
		end tell
	end tell
end ContextWithPath
