(*
Create OmniFocus Tasks for iCal events
v1.0
Dov Frankel, 2013
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
property OmniFocusLib : LibLoader's loadScript("Libraries:OmniFocus.applescript")

property theCalendarNames : {"Home", "Library Loans", "Birthdays"}

-- Initialize to false, set true if proven wrong
set anyCalendarsHaveEvents to false

-- iCloud events don't always update until iCal is activated
tell application "Calendar"
	activate
	delay 100
	quit
end tell

repeat with theCalendarName in theCalendarNames
	
	-- Necessary, strangely, because otherwise text comparisons fail	
	set theCalendarName to theCalendarName as text
	
	-- Counts the number of events in this calendar for today
	set calendarEventCount to 0
	
	--Use icalBuddy to get the lis of today's events. Formatted like so:
	--event name
	--    [notes: ]
	--    [start time - end time] (not included for all day events)
	
	set theEventList to (do shell script "/usr/local/bin/icalbuddy -iep \"title,notes,datetime\" -ic \"" & theCalendarName & "\" -nc -b \"\" eventsToday") as text
	-- get count of paragraphs, to loop through
	set paragraphCount to count of paragraphs in theEventList
	
	-- Start at first paragraph
	set paragraphNum to 1
	
	-- Loop through each paragraph
	repeat while paragraphNum ² paragraphCount
		repeat 1 times --Fake loop, to allow simulated "continue"
			
			-- The first line is always the event's summary (name)
			set eventSummary to paragraph paragraphNum of theEventList
			
			-- Initialize other properties to empty
			set eventNotes to ""
			set eventStartDate to null
			set eventEndDate to null
			
			--Go to next line
			set paragraphNum to paragraphNum + 1
			
			-- Find any additional attributes. If there's another paragraph and it begins with a space, then it's a property of the current event
			repeat while paragraphNum ² paragraphCount and paragraph paragraphNum of theEventList starts with " "
				-- Get text of property paragraph, trimming whitespace on both ends
				set nextParagraph to StringsLib's trim(paragraph paragraphNum of theEventList)
				
				-- Inside a try block in case something goes wrong, so delimiters are set back to proper value
				try
					set oldDelims to AppleScript's text item delimiters -- save their current state
					
					--If it's a notes paragraph, assign it to the eventNotes variable
					if nextParagraph starts with "notes: " then
						-- Split on "notes: " identifier
						set AppleScript's text item delimiters to {"notes: "}
						set eventNotes to text item 2 of nextParagraph
					else
						--Otherwise, parse out the two times, creating DateTime objects for both
						
						-- Times are in format below (with " - " separator)
						-- "4:00 PM - 5:00 PM"
						set AppleScript's text item delimiters to {" - "}
						
						--Get the start and end dates
						set eventStartDate to DatesLib's timeOfCurrentDate(text item 1 of nextParagraph)
						set eventEndDate to DatesLib's timeOfCurrentDate(text item 2 of nextParagraph)
						
						-- The Start Time should be a few hours earlier, as a reminder it's coming up
						set eventStartDate to eventStartDate - 3 * hours
						
					end if
					
					set AppleScript's text item delimiters to oldDelims -- restore them
				on error
					set AppleScript's text item delimiters to oldDelims -- restore them if something went wrong
				end try
				
				--Go to next line. If it's a property, this inner loop continues. If it's not, the loop breaks
				set paragraphNum to paragraphNum + 1
			end repeat -- end repeat through property lines
			
			-- Special birthday processing
			if theCalendarName = "Birthdays" then
				
				-- Trim down summary for birthdays to only the person's name				
				try -- Inside a try block in case something goes wrong, so delimiters are set back to proper value
					set oldDelims to AppleScript's text item delimiters -- save their current state
					
					set AppleScript's text item delimiters to {"'s Birthday"}
					set birthdayName to text item 1 of eventSummary
					
					set AppleScript's text item delimiters to oldDelims -- restore them
				on error
					set AppleScript's text item delimiters to oldDelims -- restore them if something went wrong
				end try
				
				-- Skip my own birthday
				if birthdayName = "My Birthday" then
					exit repeat -- Simulated "continue"
				end if
				
				-- Retrieve phone number from Address Book
				tell application "Contacts"
					set thePerson to person birthdayName
					
					ignoring case
						set thePhoneNumbers to (thePerson's phones whose label = "mobile" or label = "home" or label = "work")
					end ignoring
					
					--Look for each of the phone numbers
					repeat with thePhone in thePhoneNumbers
						if eventNotes is not equal to "" then
							-- Wrap to next line
							set eventNotes to eventNotes & "
"
						end if
						
						set eventNotes to eventNotes & thePhone's label & ": " & thePhone's value
					end repeat -- end loop while phone number is null
					
					quit
				end tell
			end if
			
			-- Interact with OmniFocus, creating a task for the current event
			--Defaults for iCal items
			set TheProject to "Miscellaneous"
			set TheContext to "Scheduled"
			
			--Change contexts or projects based on calendar
			if theCalendarName = "Library Loans" then
				set eventSummary to "Get back loaned item (" & eventSummary & ")"
				set TheContext to "People"
			else if theCalendarName = "Birthdays" then
				set eventSummary to "Birthday call: " & birthdayName
				set TheContext to "Phone"
				set TheProject to "Regular Projects:Correspondence"
			else if eventStartDate is null then
				--Don't process all-day events for other calendars
				exit repeat -- Simulated "continue"
			end if
			
			--For all-day events, set their start date to beginning of today, their end date to the end of today
			if eventStartDate is null then
				set eventStartDate to DatesLib's timeOfCurrentDate("12:00 am")
				set eventEndDate to DatesLib's timeOfCurrentDate("11:59 pm")
			end if
			
			-- Increment count of events
			set calendarEventCount to calendarEventCount + 1
			
			-- Create the new Task, assigning its Project and Context
			set newTask to OmniFocusLib's CreateTask(eventSummary, TheProject, TheContext)
			
			tell application "OmniFocus"
				tell default document
					-- Assign the rest of the task's properties
					set newTask's note to eventNotes
					set newTask's start date to eventStartDate
					set newTask's due date to eventEndDate
				end tell
			end tell
		end repeat -- end fake repeat
	end repeat --end repeat through calendar's events
	
	if calendarEventCount > 0 then
		set anyCalendarsHaveEvents to true
		tell GrowlLib to NotifyNonsticky("Added " & StringsLib's Pluralize(calendarEventCount, "event", "events") & " for calendar " & theCalendarName)
	end if
end repeat -- end repeat through calendar

if anyCalendarsHaveEvents then
	-- Update the sync server if any events were added
	tell application "OmniFocus" to tell default document to synchronize
else
	-- Notify that no events were added
	tell GrowlLib to NotifyNonsticky("No calendar events today")
end if
