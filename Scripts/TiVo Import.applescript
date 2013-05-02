property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")

-- Use when testing script
--my hazelProcessFile(POSIX file "/Users/Dov/Movies/TiVo Recordings/Days_of_our_Lives_Rafe_forgives_Sami_704 WNBCDT_1305651600.TiVo")

on hazelProcessFile(theFile)
	try
		set thePath to POSIX path of theFile
		
		-- Split out the TiVo file name and the path
		set prevTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "/"
		set mpgDir to (items 1 through -2 of (every text item of thePath)) as text
		set mpgName to ((item -1 of (every text item of thePath)) as text) & ".mpeg"
		set showName to null
		set AppleScript's text item delimiters to prevTIDs
		
		-- Provide a custom name if possible
		if mpgName contains "Days_of" then
			set today to current date
			set todayDay to (day of today as number) as text
			if todayDay's length < 2 then
				set todayDay to "0" & todayDay
			end if
			set todayMonth to (month of today as number) as text
			if todayMonth's length < 2 then
				set todayMonth to "0" & todayMonth
			end if
			set dateString to (year of today & "-" & todayMonth & "-" & todayDay) as text
			set mpgName to "Days of our Lives (" & dateString & ").mpeg"
			set showName to "Days of our Lives"
		end if
		
		-- Put the parts together
		set mpgPath to mpgDir & "/" & mpgName
		
		-- Decode the TiVo file
		set tiVoDecodeCommand to "/usr/local/bin/tivodecode --mak 7350832565 --dump-metadata --out " & quoted form of mpgPath & " " & quoted form of thePath
		--log tiVoDecodeCommand
		do shell script tiVoDecodeCommand
		
		-- Figure out the converted file's name
		--set convertedDir to "/Volumes/Max Rebo/AppleTV Encoded"
		set convertedDir to "/Volumes/Max Rebo/iTunes/iTunes Media"
		set convertedFile to StringsLib's replace_text(mpgName, ".mpeg", ".m4v")
		set convertedPath to convertedDir & "/" & convertedFile
		
		-- Convert the MPEG file using Handbrake
		set handbrakeCommand to "/Applications/HandBrakeCLI -i " & quoted form of mpgPath ¬
			& " -o " & quoted form of convertedPath ¬
			& " --preset='AppleTV 2'"
		--log handbrakeCommand
		do shell script handbrakeCommand
		
		-- Turn Speed Limit on
		tell TransmissionLib to initialize()
		tell TransmissionLib to ToggleSpeedLimit(true)
		
		-- Add the file to iTunes
		set m4vFile to POSIX file convertedPath
		set itunesTrack to null
		tell application "iTunes"
			set itunesTrack to add m4vFile
			
			set video kind of itunesTrack to TV show
			if showName is not null then set show of itunesTrack to showName
			set trackId to itunesTrack's database ID
			
			tell application "iFlicks" to update track trackId
		end tell
		
		-- Tweak release date in iFlicks to get the proper tags to load
		activate application "iFlicks"
		delay 60
		tell application "System Events"
			tell process "iFlicks"
				select image "Days of our Lives" of UI element 1 of scroll area 1 of window 1
				click menu item "Get Info" of menu 1 of menu bar item "File" of menu bar 1
				delay 15
				
				set releaseFieldDateIndex to 12
				
				select text field releaseFieldDateIndex of sheet 1 of window 1
				set value of text field releaseFieldDateIndex of sheet 1 of window 1 to short date string of (current date)
				click button "Reload" of sheet 1 of window 1
				delay 15
				click button "Ok" of sheet 1 of window 1
				delay 15
				click button "Start" of window 1
				delay 15
			end tell
		end tell
		
		tell application "iFlicks" to quit
		
		-- Give the episode a title, if it has none
		tell application "iTunes"
			if name of itunesTrack = "Episode 0" then
				set name of itunesTrack to date string of (current date)
			end if
		end tell
		
		-- Clean up intermediate files
		--tell GrowlLib to Notify("mpgPath: '" & mpgPath & "'")
		set mpgFile to POSIX file mpgPath
		tell application "Finder"
			move file theFile to the trash
			move file mpgFile to the trash
		end tell
		
		tell GrowlLib to Notify("Added show: " & mpgName)
		
	on error errorMessage
		tell GrowlLib to Notify("Error adding show: " & errorMessage)
	end try
	
	tell TransmissionLib to Finalize()
end hazelProcessFile
