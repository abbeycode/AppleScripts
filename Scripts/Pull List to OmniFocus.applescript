property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property OmniFocusLib : LibLoader's loadScript("Libraries:OmniFocus.applescript")

property isDebugging : false

if not isDebugging then
	tell TransmissionLib to Initialize()
	tell TransmissionLib to ToggleSpeedLimit(true)
end if

set pullListDate to current date

set monthStr to (pullListDate's month as number) as text
if monthStr's length = 1 then set monthStr to "0" & monthStr

set dayStr to (pullListDate's day as number) as text
if dayStr's length = 1 then set dayStr to "0" & dayStr

set pullListDateUrl to pullListDate's year & "/" & monthStr & "/" & dayStr as text
set theUrl to "https://leagueofcomicgeeks.com/profile/dov/pull-list/" & pullListDateUrl

try
	-- Open up the list in a new window and get its full text
	tell SafariLib to LoadUrlInNewWindow(theUrl)
	
	-- Initialize variables
	set titles to {"Downloaded:"}
	set pullListDate to missing value
	
	tell application "Safari"
		set doc to front document
		set comicTitles to do JavaScript "$('.comic-title a').map(function(){ return $(this).text() }).toArray()" in doc
		set loadedURL to (URL of doc) as string
	end tell
	
	set titles to titles & comicTitles
	set pullListDateText to text -10 through -1 of loadedURL
	set pullListDate to current date
	set year of pullListDate to text 1 through 4 of pullListDateText as integer
	set month of pullListDate to text 6 through 7 of pullListDateText as integer
	set day of pullListDate to text 9 through 10 of pullListDateText as integer
on error errMsg
	display dialog errMsg
end try

tell SafariLib to CloseWindow()

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