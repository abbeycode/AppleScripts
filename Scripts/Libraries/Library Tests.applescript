(*
Library Tests
v1.0
Dov Frankel, 2013
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property FilenamesLib : LibLoader's loadScript("Libraries:Filenames.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property iTunesLib : LibLoader's loadScript("Libraries:iTunes.applescript")

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

my TestStrings()

my TestDates()
my TestStrings()
my TestFilenames()

my Test_iTunes()
my TestTransmission()
--my TestGrowl()

log ("All tests passed with flying colors!!!!!")

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- *************************    Transmission    *************************
-- ****************************************************************

on TestTransmission()
	log ("START TRANSMISSION TESTS")
	
	-- Test, then test flipped
	repeat with testSpeedLimitValue in {true as boolean, false as boolean}
		-- Turn off delays so testing goes faster
		tell TransmissionLib to TurnDelayOff()
		
		-- Initialize text to read either "on" or "off"
		set speedLimitOnOffText to "on"
		set oppositeText to "off"
		if testSpeedLimitValue = false then
			set speedLimitOnOffText to "off"
			set oppositeText to "on"
		end if
		
		-- Set initial Speed Limit state
		tell TransmissionLib to ToggleSpeedLimit(testSpeedLimitValue)
		
		-- Set up initialization/finalization
		set speedLimitWasOnBeforeTest to TransmissionLib's SpeedLimitIsOn()
		tell TransmissionLib to initialize()
		
		repeat 2 times
			-- Test with Speed Limit <> testSpeedLimitValue
			log ("TEST: ToggleSpeedLimit(" & (not testSpeedLimitValue) & "), negated")
			tell TransmissionLib to ToggleSpeedLimit(not testSpeedLimitValue)
			my test(TransmissionLib's SpeedLimitIsOn() = (not testSpeedLimitValue), "Speed Limit didn't turn " & oppositeText)
			delay 1
		end repeat
		
		repeat 2 times
			-- Test with Speed Limit = testSpeedLimitValue
			log ("TEST: ToggleSpeedLimit(" & testSpeedLimitValue & ")")
			tell TransmissionLib to ToggleSpeedLimit(testSpeedLimitValue)
			my test(TransmissionLib's SpeedLimitIsOn() = (testSpeedLimitValue as boolean), "Speed Limit didn't turn " & speedLimitOnOffText)
			delay 1
		end repeat
		
		-- Finalize
		log ("TEST: Finalize()")
		tell TransmissionLib to Finalize()
		my test(TransmissionLib's SpeedLimitIsOn() = speedLimitWasOnBeforeTest, "After Finalize Speed Limit doesn't match before Initialize")
		
	end repeat
	
	log ("TRANSMISSION PASSED

")
end TestTransmission

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- ****************************    Growl    ****************************
-- ****************************************************************

on TestGrowl()
	log ("START GROWL TESTS")
	
	tell GrowlLib to Notify("GrowlLib test passed")
	
	log ("GROWL PASSED

")
end TestGrowl

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- ****************************    Strings    ***************************
-- ****************************************************************

on TestStrings()
	log ("START STRINGS TESTS")
	
	-- Test Pluralize
	repeat with Quantity from 0 to 3
		log ("TEST: Pluralize(" & Quantity & ",'item','items')")
		set pluralized to StringsLib's Pluralize(Quantity, "item", "items")
		
		if Quantity = 0 then
			set expected to "0 items"
		else if Quantity = 1 then
			set expected to "1 item"
		else if Quantity = 2 then
			set expected to "2 items"
		else if Quantity = 3 then
			set expected to "3 items"
		end if
		
		my testExpectedActual(expected, pluralized)
	end repeat
	
	-- Test Trim
	set whiteSpaceChars to {Â
		" " as text, Â
		tab as text, Â
		(ASCII character 10) as text, Â
		return as text, Â
		(ASCII character 0) as text, Â
		""}
	
	repeat with firstLeadingSpace in whiteSpaceChars
		repeat with secondLeadingSpace in whiteSpaceChars
			repeat with firstTrailingSpace in whiteSpaceChars
				repeat with secondTrailingSpace in whiteSpaceChars
					repeat with substance in {"a", "1", "a 1", "1 a", "abcd 123"}
						set substance to substance as text
						set testString to firstLeadingSpace & secondLeadingSpace & substance & firstTrailingSpace & secondTrailingSpace
						log ("TEST: trim('" & testString & "')")
						set trimmed to StringsLib's trim(testString)
						my testExpectedActual(substance, trimmed)
					end repeat
				end repeat
			end repeat
		end repeat
	end repeat
	
	-- Test Split
	set dataStrings to {"a", "aaa", "b2df4;", "abra cadabra"}
	set dataDelimiters to {",", ":"}
	
	repeat with delim in dataDelimiters
		set testStr to item 1 of dataStrings
		
		repeat with i from 2 to count of dataStrings
			set testStr to testStr & delim & item i of dataStrings
		end repeat
		
		log ("TEST: Split('" & delim & "','" & testStr & "')")
		set splitted to StringsLib's split(delim, testStr)
		
		repeat with i from 1 to count of dataStrings
			my testExpectedActual(item i of dataStrings, item i of splitted)
		end repeat
	end repeat
	
	-- Test Replace Text
	set inputStrings to {"abcd", "aabcd", "abcda", "an opera"}
	set searchString to "a"
	set replaceString to "x"
	set outputStrings to {"xbcd", "xxbcd", "xbcdx", "xn operx"}
	
	repeat with i from 1 to count of inputStrings
		set inputString to item i of inputStrings
		log ("TEST: replace_text('" & inputString & "','" & searchString & "','" & replaceString & "')")
		set replaced to StringsLib's replace_text(inputString, searchString, replaceString)
		
		my testExpectedActual(item i of outputStrings, replaced)
	end repeat
	
	log ("STRINGS PASSED

")
end TestStrings

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- ****************************    Dates    ****************************
-- ****************************************************************

on TestDates()
	log ("START DATES TESTS")
	
	set testDt to date ("01/01/2001")
	set testTime to "5:00 am"
	log ("TEST: timeOfDate('" & testDt & "','" & testTime & "')")
	set actual to DatesLib's timeOfDate(testDt, testTime)
	set expected to "Monday, January 1, 2001 5:00:00 AM"
	my testExpectedActual(expected, actual as string)
	
	log ("TEST: timeOfCurrentDate('" & testTime & "')")
	set expected to DatesLib's timeOfDate(current date, testTime)
	set actual to DatesLib's timeOfCurrentDate(testTime)
	my testExpectedActual(expected, actual)
	
	set dateMatchData to {Â
		{date ("12/1/10"), date ("12/1/10"), true}, Â
		{date ("12/1/10"), date ("12/2/10"), false}, Â
		{date ("12/2/10"), date ("12/1/10"), false}, Â
		{date ("12/1/10 12:00am"), date ("12/1/10 1:00am"), true}, Â
		{date ("12/1/10 12:00am"), date ("12/2/10 12:00am"), false}, Â
		{date ("12/1/10"), missing value, false}, Â
		{missing value, date ("12/1/10"), false}, Â
		{missing value, missing value, true} Â
			}
	repeat with TestDates in dateMatchData
		set LeftDate to item 1 of TestDates
		set RightDate to item 2 of TestDates
		set expected to item 3 of TestDates
		log ("TEST: datesMatch('" & LeftDate & "', '" & RightDate & "')")
		set actual to DatesLib's datesMatch(LeftDate, RightDate)
		my testExpectedActual(expected, actual)
	end repeat
	
	set testDt to date ("01/01/2001")
	set testTime to "5:00 am"
	set testDt to DatesLib's timeOfDate(testDt, testTime)
	set testNumDays to 1
	set expectedDt to date ("01/02/2001")
	set expected to DatesLib's timeOfDate(expectedDt, testTime)
	log ("TEST: addDays('" & testDt & "'," & testNumDays & ")")
	set actual to DatesLib's addDays(testDt, testNumDays)
	my testExpectedActual(expected, actual)
	
	log ("DATES PASSED

")
end TestDates

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- **************************    Filenames    ***************************
-- ****************************************************************

on TestFilenames()
	log ("START FILENAMES TESTS")
	
	repeat with FilePath in {"http://interfacelift.com/wallpaper_beta/grab/02331_veiledinclouds_2560x1600.jpg", "/Users/abc/Downloads/02331_veiledinclouds_2560x1600.jpg"}
		log ("TEST: GetExtension('" & FilePath & "')")
		set extension to FilenamesLib's GetExtension(FilePath)
		my testExpectedActual("jpg", extension)
		
		log ("TEST: GetFileName('" & FilePath & "')")
		set filename to FilenamesLib's GetFileName(FilePath)
		my testExpectedActual("02331_veiledinclouds_2560x1600.jpg", filename)
	end repeat
	
	log ("FILENAMES PASSED

")
end TestFilenames

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


-- ****************************************************************
-- ***************************    iTunes    ****************************
-- ****************************************************************

on Test_iTunes()
	log ("START iTUNES TESTS")
	
	repeat with SourceName in {"Greedo", "Music"}
		log ("TEST: SelectSource('" & SourceName & "')")
		set selectSuccess to iTunesLib's SelectSource(SourceName)
		test(selectSuccess = true, SourceName & " not selected")
		
		set SourceName to SourceName & "$doesn't exist"
		
		log ("TEST: SelectSource('" & SourceName & "')")
		set selectSuccess to iTunesLib's SelectSource(SourceName)
		test(selectSuccess = false, SourceName & " selected, though it shouldn't exist")
	end repeat
	
	set aTv to "Doesn't Exist"
	log ("TEST: SyncAppleTv('" & aTv & "')")
	set syncSuccess to iTunesLib's SyncAppleTv(aTv)
	test(syncSuccess = false, "Synced non-existent device")
	
	repeat with aTv in {"Greedo", "Sy Snootles"}
		
		log ("TEST: SyncAppleTv('" & aTv & "')")
		set syncSuccess to iTunesLib's SyncAppleTv(aTv)
		test(syncSuccess = true, "Did not sync")
		
		log ("TEST: SyncAppleTv('" & aTv & "')")
		set syncSuccess to iTunesLib's SyncAppleTv(aTv)
		test(syncSuccess = false, "Synced while already syncing?")
		
	end repeat
	
	log ("iTUNES PASSED

")
end Test_iTunes

-- ///////////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



on testExpectedActual(ExpectedVal, ActualVal)
	my test(ExpectedVal is equal to ActualVal, "Expected: '" & ExpectedVal & "', Actual: '" & ActualVal & "'")
end testExpectedActual

on test(ErrCondition, errMessage)
	if ErrCondition is not true then
		log ("    FAILED: " & errMessage)
		error errMessage
	end if
end test
