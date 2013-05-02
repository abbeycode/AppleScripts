property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)

my DownloadChristineActivity()
delay 5
my DownloadDovActivity()

tell GrowlLib to NotifyNonsticky("Downloaded Chase Activity")
tell TransmissionLib to Finalize()



on LogIntoChase(theUsername, thePassword)
	-- Load a new window for Chase's site
	SafariLib's LoadUrlInNewWindow("https://chaseonline.chase.com/")
	
	tell application "Safari"
		set doc to document "Chase Online - Logon"
		delay 2
		set loginUrl to doc's URL
		
		-- Fill in username and password, and submit form	
		do JavaScript "document.forms['Started']['UserID'].value = '" & theUsername & "'" in doc
		do JavaScript "document.forms['Started']['Password'].value = '" & thePassword & "'" in doc
		do JavaScript "document.getElementById('logon').click()" in doc
	end tell -- Safari
	
	SafariLib's WaitForFrontWindowToLoadIgnoringUrlContainingString(loginUrl, "MyAccounts.aspx")
end LogIntoChase

on DownloadActivity(downloadPageUrl, formName, selectFieldName)
	SafariLib's LoadUrlInFrontWindow(downloadPageUrl)
	
	tell application "Safari"
		set doc to document "Chase Online - Download Activity"
		
		-- Tell it you want to choose a date range
		do JavaScript "document.forms['" & formName & "']['SelectDateRange'].click()" in doc
		
		-- Specify beginning date
		set beginDate to DatesLib's addDays(current date, -8)
		set beginDateStr to DatesLib's formatDate(beginDate)
		do JavaScript "document.forms['" & formName & "']['FromDate_Value'].value = '" & beginDateStr & "'" in doc
		
		-- Specify ending date
		set endDateStr to DatesLib's formatDate(current date)
		do JavaScript "document.forms['" & formName & "']['ToDate_Value'].value = '" & endDateStr & "'" in doc
		
		-- Tell it to download QFX, and submit
		do JavaScript "document.forms['" & formName & "']['" & selectFieldName & "'].value = 'QFX'" in doc
		do JavaScript "document.getElementById('BtnDownloadActivity').click()" in doc
	end tell
end DownloadActivity

on NameActivityFile(newFilename, oldFilename)
	
	-- Wait for it to download
	delay 10
	
	set downloadPath to POSIX path of (path to downloads folder)
	
	try
		set activityFile to POSIX file (downloadPath & oldFilename & ".QFX") as alias
		
		set docName to "Chase Activity (" & newFilename & ").QFX"
		log "renaming " & oldFilename & ".QFX to ' " & docName & "'"
		
		tell application "Finder" to set name of activityFile to (docName as text)
	on error
		log "Error getting activity. Most likely no activity in last week"
	end try
	
end NameActivityFile

on DownloadChristineActivity()
	my LogIntoChase("christine_username", "christine_password")
	my DownloadActivity("https://cards.chase.com/Account/DownloadActivity.aspx?AI=15034197", "Form1", "DownloadType")
	my NameActivityFile("Christine Visa", "Activity")
	tell SafariLib to CloseWindow()
end DownloadChristineActivity

on DownloadDovActivity()
	my LogIntoChase("dov_username", "dov_password")
	
	-- Checking
	my DownloadActivity("https://banking.chase.com/AccountActivity/AccountActivityForm.aspx?AI=97920887", "DownloadActivity", "DownloadTypes")
	my NameActivityFile("Checking", "JPMC")
	
	-- Savings
	my DownloadActivity("https://banking.chase.com/AccountActivity/AccountActivityForm.aspx?AI=96578493", "DownloadActivity", "DownloadTypes")
	my NameActivityFile("Savings", "JPMC")
	
	-- Sapphire
	my DownloadActivity("https://cards.chase.com/Account/DownloadActivity.aspx?AI=98092892", "Form1", "DownloadType")
	my NameActivityFile("Sapphire", "Activity")
	
	tell SafariLib to CloseWindow()
end DownloadDovActivity
