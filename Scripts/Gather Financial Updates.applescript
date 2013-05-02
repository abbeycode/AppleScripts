(*
Gather Financial Updates
v1.0
Dov Frankel, 2013
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")

-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)


run script file "Skywalker:Users:Dov:Library:Scripts:Get 401k Prices.applescript"
set the401kInfo to (get the clipboard as Unicode text)

run script file "Skywalker:Users:Dov:Library:Scripts:Get Receipts from Notes.applescript"
set theNotesReceipts to (get the clipboard as Unicode text)


set outMessage to the401kInfo & "

" & theNotesReceipts


-- Open up text window for copy/paste of results
tell application "TextEdit"
	activate
	set doc to make new document
	set doc's text to outMessage
end tell


tell GrowlLib to NotifyNonsticky("Financial info gathered")
tell TransmissionLib to Finalize()