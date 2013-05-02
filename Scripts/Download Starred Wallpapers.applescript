property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property FilenamesLib : LibLoader's loadScript("Libraries:Filenames.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")

property isDebugging : false


-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)

tell application "NetNewsWire"
	set interfaceLift to item 1 of (subscriptions whose display name is "InterfaceLIFT")
	
	-- Make sure subscriptions are up to date
	refresh interfaceLift
	
	if not isDebugging then delay 15 -- Give the refresh a chance to finish
	set flaggedHeadlines to every headline of interfaceLift whose isFlagged = true
end tell -- end tell "NetNewsWire"

repeat with head in flaggedHeadlines
	set theUrl to ""
	tell application "NetNewsWire" to set theUrl to head's URL as text
	
	tell application "Safari"
		-- Browse to wallpaper page
		tell SafariLib to LoadUrlInNewWindow(theUrl)
		activate
		
		-- Get reference to loaded page
		set doc to front document
		
		-- Get unique references for this wallpaper
		set wallpaperId to my getWallpaperId(theUrl)
		set divId to "download_" & wallpaperId
		
		-- Download 1920x1200 version
		set theUrl2 to do JavaScript "document.getElementById('" & divId & "').childNodes[0].href" in doc
		if not isDebugging then my downloadImage(theUrl2)
		
		-- Change page to 2560x1600 version
		do JavaScript "document.getElementById('res_2560x1600_1').selected = true; document.getElementById('res_2560x1600_1').parentNode.parentNode.onchange();" in doc
		
		tell SafariLib to WaitForFrontWindowToLoad()
		
		-- Download 2560x1600 version
		set theUrl3 to do JavaScript "document.getElementById('" & divId & "').childNodes[0].href" in doc
		if not isDebugging then my downloadImage(theUrl3)
	end tell -- tell Safari
	
	tell SafariLib to CloseWindow()
	
	-- Unflag (unstar) wallpaper
	tell application "NetNewsWire"
		set head's isRead to no
		activate
		delay 1
		set head's isFlagged to no
		set head's isFollowed to yes
		set head's isRead to yes
		activate
		delay 1
		
		if isDebugging then
			activate
			delay 1
		end if
	end tell
end repeat -- repeat with each URL from NNW

-- Sync changes back to Google Reader
tell application "NetNewsWire" to refresh interfaceLift

tell GrowlLib to NotifyNonsticky("Downloaded " & StringsLib's Pluralize(count of flaggedHeadlines, "starred wallpaper", "starred wallpapers"))

tell TransmissionLib to Finalize()


on getWallpaperId(fromUrl)
	try
		
		set oldDelims to AppleScript's text item delimiters -- save their current state
		set AppleScript's text item delimiters to {"/"}
		
		set theId to text item 6 of fromUrl
		return theId
		
	on error errMessage
		set AppleScript's text item delimiters to oldDelims -- restore them if something went wrong
		log "getWallpaperId(fromUrl) failed: " & errMessage
	end try
	
end getWallpaperId

on downloadImage(imageUrl)
	--log "Downloading from URL " & imageUrl
	set imageFileName to FilenamesLib's GetFileName(imageUrl)
	--log "imageFileName: " & imageFileName
	set downloadFolder to (POSIX path of (path to downloads folder))
	set downloadFile to quoted form of (downloadFolder & imageFileName)
	
	--log "Downloading to " & downloadFile
	do shell script "curl -L -A 'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50' -o " & downloadFile & " " & imageUrl
end downloadImage
