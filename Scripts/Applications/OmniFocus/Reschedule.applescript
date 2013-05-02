property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

set DEBUGGING to false

tell application "OmniFocus"
	set theSelection to get get value of selected tree of content of document window 1 of default document
	
	-- Try to get a valid selection
	set theSelection to my correctedSelection(theSelection)
	
	-- Give up if a valid selection can't be determined	
	if theSelection = null then return
	
	-- Prompt user for days into future to reschedule the tasks by
	if not DEBUGGING then
		try
			set theResult to display dialog "How many days should these tasks be rescheduled by?" default answer ""
		on error number -128 -- User Cancelled
			return
		end try
		
		set rescheduleBy to text returned of theResult as integer
	else
		set rescheduleBy to (1 as integer)
	end if
	
	repeat with theTask in theSelection
		set theStartDate to theTask's start date
		set theDueDate to theTask's due date
		set theDatesMatch to DatesLib's datesMatch(theStartDate, theDueDate)
		
		-- Correct Start Date
		if theStartDate is not missing value then set theTask's start date to Â
			DatesLib's addDays(theStartDate, rescheduleBy)
		
		-- Correct Due Date (only if Start and Due initially matched, or only Due Date is assigned - assumption made that both can't be missing, verified above)
		if theDatesMatch or theStartDate is missing value then set theTask's due date to Â
			DatesLib's addDays(theDueDate, rescheduleBy)
	end repeat
end tell

on correctedSelection(selectedItems)
	set selectionContainsInvalidItems to false
	set newSelectedItems to {}
	set errorMessage to "Please select some tasks in OmniFocus"
	if selectedItems is not {} then
		repeat with theItem in selectedItems
			tell application "OmniFocus"
				set itemHasDates to my itemHasStartOrDueDate(theItem)
				
				
				
				if itemHasDates then
					log "Item has dates"
					if not my listContainsOmniFocusItem(newSelectedItems, theItem) then set newSelectedItems to newSelectedItems & {theItem}
				else
					set itemHasDates to my itemHasStartOrDueDate(theItem's container)
					
					if itemHasDates then
						log "container has dates"
						if not my listContainsOmniFocusItem(newSelectedItems, theItem's container) then set newSelectedItems to newSelectedItems & {theItem's container}
					else
						log "neither has dates"
						-- If neither it not its container has start or due dates, it's not valid
						set errorMessage to "'" & theItem's name & "' has no start or due dates"
						set selectionContainsInvalidItems to true
						exit repeat
					end if
				end if
			end tell
		end repeat -- Loop through selected items
	end if
	
	if newSelectedItems is {} or selectionContainsInvalidItems then
		display dialog errorMessage buttons {"OK"} default button 1
		return null
	end if
	
	repeat with theItem in newSelectedItems
		log "selected: " & (theItem's name)
	end repeat
	
	return newSelectedItems
end correctedSelection

on itemHasStartOrDueDate(theItem)
	try
		tell application "OmniFocus"
			log "Checking item " & theItem's name & " for dates"
			
			-- If this line runs without error, theItem is a Task
			set theStartDate to theItem's start date
			set theDueDate to theItem's due date
			
			log "start: " & theStartDate & "; due: " & theDueDate
			
			-- If it has no start or due dates, it's not valid
			return theStartDate is not missing value or theDueDate is not missing value
		end tell
	on error
		return false
	end try
end itemHasStartOrDueDate

on listContainsOmniFocusItem(theList, theItem)
	repeat with listItem in theList
		tell application "OmniFocus"
			if listItem's id = theItem's id then return true
		end tell
	end repeat
	
	return false
end listContainsOmniFocusItem