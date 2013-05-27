on run {input, parameters}
	set handbrakeCli to "/Applications/HandBrakeCLI"
	set defaultPreset to 7
	
	-- Make sure HandBrakeCLI is installed
	set handbrakeInstalled to false
	tell application "Finder" to if exists handbrakeCli as POSIX file then set handbrakeInstalled to true
	if not handbrakeInstalled then
		display alert "Install HandBrake CLI" message "Please install HandBrakeCLI into the /Applications directory

The HandBrake CLI can be downloaded at http://handbrake.fr/downloads2.php" as critical
		return
	end if
	
	set the destination to POSIX path of (choose folder with prompt "Select the conversion destination")
	
	set the presetList to do shell script handbrakeCli & " -z"
	
	set eachPreset to every paragraph of presetList
	
	set groupEx to re_compile "<[ ]*(.+)"
	set presetEx to re_compile "[ ]*\\+[ ]*([^:]*):"
	
	set displayNames to {}
	set presetNames to {}
	
	set group to ""
	
	repeat with preset in eachPreset
		if length of preset > 0 then
			if preset starts with "<" then
				-- Pull out the group's name
				set group to find text groupEx in preset using "\\1" with regexp and string result
			else if preset contains "+" then
				set presetName to find text presetEx in preset using "\\1" with regexp and string result
				copy presetName to end of presetNames
				copy group & " > " & presetName to end of displayNames
			end if
		end if
	end repeat
	
	set chosenDisplayPreset to choose from list displayNames with title "HandBrake preset" with prompt "Choose a HandBrake preset" default items {item defaultPreset of displayNames}
	
	if chosenDisplayPreset = false then
		return
	end if
	
	set chosenDisplayPreset to chosenDisplayPreset as text
	
	set presetIndex to 1
	repeat with i from 1 to (count of items in displayNames)
		if item i of displayNames is equal to chosenDisplayPreset then
			set presetIndex to i
			exit repeat
		end if
	end repeat
	
	set chosenPreset to item presetIndex of presetNames
	
	repeat with inputFile in input
		-- Get original file's name
		
		set thePath to POSIX path of inputFile
		set prevTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "/"
		-- Get the file name
		set inputFileName to (item -1 of (every text item of thePath)) as text
		
		-- Get the file name without an extension
		set AppleScript's text item delimiters to "."
		set inputFileNoExtension to items 1 through -2 of (every text item of inputFileName)
		set AppleScript's text item delimiters to prevTIDs
		
		-- Put back together if file name included periods
		set outputFileName to ""
		repeat with fileNamePart in inputFileNoExtension
			set outputFileName to outputFileName & fileNamePart & "."
		end repeat
		
		-- Put on the preferred extension
		set outputFileName to outputFileName & "m4v"
		
		set handbrakeCommand to "nice " & handbrakeCli & " -i " & quoted form of (POSIX path of inputFile) & " -o " & quoted form of (destination & outputFileName) & " --preset='" & chosenPreset & "'"
		--return handbrakeCommand
		do shell script handbrakeCommand
	end repeat
	return input
end run