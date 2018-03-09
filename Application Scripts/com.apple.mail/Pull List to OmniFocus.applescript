property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property OmniFocusLib : LibLoader's loadScript("Libraries:OmniFocus.applescript")

property isDebugging : false
property isManualRun : false

-- Necessary to use the "perform mail action" handler below
using terms from application "Mail"
	
	-- Only runs when executing the script from AppleScript Editor
	set isDebugging to true
	tell application "Mail"
		-- Rather than running as a rule, use the current selection
		set debugMessages to selection
		my MakePullList(debugMessages)
	end tell
	
	on perform mail action with messages ruleMessages for rule theRule
		MakePullList(ruleMessages)
	end perform mail action with messages
	
end using terms from

on MakePullList(theMessages)
	if not isDebugging then
		tell TransmissionLib to Initialize()
		tell TransmissionLib to ToggleSpeedLimit(true)
	end if
	
	if not isManualRun then
		-- Initialize variables
		set theUrl to ""
		set printUrlParagraph to ""
		
		-- Takes the subject of the last message, in case multiples are selected
		tell application "Mail"
			repeat with eachMessage in theMessages
				set theSubject to subject of eachMessage
			end repeat -- message loop
		end tell -- Mail
		
		-- Pull out the date from the subject line
		set dateStart to (offset of " for " in theSubject) + 5
		set theDateStr to items dateStart thru end of theSubject as text
		
		-------- Use the date to build up the url of the print version of the pull list
		
		-- Turn from String into date
		set pullListDate to date theDateStr
		
		set monthStr to (pullListDate's month as number) as text
		if monthStr's length = 1 then set monthStr to "0" & monthStr
		
		set dayStr to (pullListDate's day as number) as text
		if dayStr's length = 1 then set dayStr to "0" & dayStr
		
		set pullListDateUrl to pullListDate's year & "/" & monthStr & "/" & dayStr as text
		set theUrl to "http://pulllist.comixology.com/pulllist/" & pullListDateUrl
	end if
	
	try
		-- Open up the list in a new window and get its full text
		if not isManualRun then tell SafariLib to LoadUrlInNewWindow(theUrl)
		
		-- Initialize variables
		set titles to {"Downloaded:"}
		set pullListDate to missing value
		
		tell application "Safari"
			set doc to front document
			set comicTitles to do JavaScript "$('a', 'div#title').map(function(){ return $(this).text() }).toArray().filter(Boolean)" in doc
			set pageTitle to (name of doc) as string
			set pullListDateText to «event SATIFINd» "Your Pull List for (.*) - comiXology" with «class UsGR» and «class WaMr» given «class $in »:pageTitle, «class by  »:"\\1"
		end tell
		
		set titles to titles & comicTitles
		set pullListDate to date pullListDateText
	on error errMsg
		display dialog errMsg
	end try
	
	if not isManualRun then tell SafariLib to CloseWindow()
	
	-- Make a pretty formatted date out of the date, and create the OmniFocus tasks
	set dateStr to ((pullListDate's month as integer) & "/" & pullListDate's day & "/" & pullListDate's year) as text
	set weekTask to OmniFocusLib's CreateTask(dateStr, "Lists:Comics", "Home:Computer:Downloads")
	repeat with title in titles
		tell OmniFocusLib to CreateTask(title, weekTask, "Home:Computer:Downloads")
	end repeat
	
	if not isDebugging then
		tell GrowlLib to NotifyNonsticky("Pull List copied to OmniFocus")
		tell TransmissionLib to Finalize()
	end if
	
	tell application "Mail"
		repeat with eachMessage in theMessages
			set read status of eachMessage to true
			set mailbox of eachMessage to mailbox "Archive" of imap account "iCloud"
		end repeat -- message loop
	end tell -- Mail
end MakePullList