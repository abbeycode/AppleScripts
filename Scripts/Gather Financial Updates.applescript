(*
Gather Financial Updates
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Runs other scripts, which each copy their results to the clipboard, and pastes the results into a new TextEdit document

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")

-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)


-- The scripts below both return strings
set the401kInfo to LibLoader's runScript("Get 401k Prices.applescript")
set theNotesReceipts to LibLoader's runScript("Get Receipts from Notes.applescript")
set sallieMaeSplits to LibLoader's runScript("Get Sallie Mae Loan Splits.applescript")


set outMessage to the401kInfo & "

" & theNotesReceipts & "

" & sallieMaeSplits


-- Open up text window for copy/paste of results
tell application "TextEdit"
	activate
	set doc to make new document
	set doc's text to outMessage
end tell


tell GrowlLib to NotifyNonsticky("Financial info gathered")
tell TransmissionLib to Finalize()
