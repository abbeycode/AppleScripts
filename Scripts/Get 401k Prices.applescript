property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)

set sacSharePrice to my getPrincipalSharePrice()
set sacContributions to my getPrincipalContributions()

set outMessage to "401k Price
SAC 401(k)   " & sacSharePrice's shareDate & "   " & sacSharePrice's sharePrice & "


" & sacContributions

-- Open up text window for copy/paste of results
tell application "TextEdit"
	activate
	set doc to make new document
	set doc's text to outMessage
end tell


tell GrowlLib to NotifyNonsticky("401k share prices downloaded")
tell TransmissionLib to Finalize()

-----------------------------------------------------------------------------
on getPrincipalSharePrice()
	tell application "Safari"
		SafariLib's LoadUrlInNewWindow("http://www.principal.com/InvestmentProfiles/performance.faces?inv=4568&rtclss=68&retail=false")
		
		set doc to document "Principal LifeTime 2050 Separate Account-I3"
		do JavaScript "document.getElementById('idc-fundchart-export').click()" in doc
	end tell
	
	tell application "Finder"
		set csvFilePath to POSIX path of ((path to downloads folder as text) & "chartdata.csv")
		
		repeat until exists csvFilePath as POSIX file
			delay 0.5
		end repeat
	end tell
	
	set dateValue to my getFirstRowFieldFromCSV(csvFilePath, "Date")
	set priceValue to my getFirstRowFieldFromCSV(csvFilePath, "Unit Value/Share Price")
	
	set csvFile to POSIX file csvFilePath
	tell application "Finder" to move csvFile to trash
	
	-- All done with the window, close it	
	tell SafariLib to CloseWindow()
	
	return {shareDate:dateValue, sharePrice:priceValue}
end getPrincipalSharePrice

on getFirstRowFieldFromCSV(csvPath, csvField)
	set pythonScript to "
import csv

filename = '" & csvPath & "'

with open(filename, 'rb') as f:
    reader = csv.reader(f)
    headers = reader.next()
    first_data_row = reader.next()
    print(first_data_row[headers.index('" & csvField & "')])
"
	
	return do shell script "/usr/bin/env python -c \"" & pythonScript & "\""
end getFirstRowFieldFromCSV

on getPrincipalContributions()
	my logOntoPrincipalSite()
	
	SafariLib's LoadUrlInFrontWindow("https://secure05.principal.com/RetirementServiceCenter/memberview?page_name=reqonline")
	
	tell application "Safari"
		set doc to document "Activity Detail"
		
		set monthAgo to DatesLib's formatDate(DatesLib's addDays(current date, -35))
		
		do JavaScript "document.getElementById('From').value = '" & monthAgo & "'" in doc
		do JavaScript "document.getElementById('ByInv').checked = true" in doc
		do JavaScript "Validate('submit')" in doc
		do JavaScript "document.forms[0].submit()" in doc
		
		SafariLib's WaitForFrontWindowToLoad()
		set doc to document "Activity Detail By Investment and All Contribution Types"
		do JavaScript "document.getElementById('ResultTable').outerHTML" in doc
		
		set activityTable to do JavaScript "
		function returnValue() {
			var tbody = document.getElementById('ResultTable').tBodies[1];
			var result = 'Date\\t\\t\\tActivity\\t\\tAmount\\tShare Price\\tShares\\n';
			
			var r = 0;
			while (row = tbody.rows[r++]) {
				if (row.cells[0].colSpan > 1)
					continue;
				
				var rowText = '';
			
				var c = 0;
				while (cell = row.cells[c++]) {
					rowText += cell.innerHTML.trim() + '\\t';
				}
				
				result += rowText.trim() + '\\n';
			}
			
			return result.trim();
		}
		
		returnValue();
		" in doc
		
		-- All done with the window, close it	
		tell SafariLib to CloseWindow()
		
		return "SAC Contributions:

" & activityTable
	end tell
end getPrincipalContributions

on logOntoPrincipalSite()
	tell application "Safari"
		-- Load a new window for the Principal site
		SafariLib's LoadUrlInNewWindow("https://www.principal.com")
		
		activate
		delay 2
		
		set doc to document "Principal.com: 401k plans, investment management, insurance, mutual funds and more"
		
		-- Log in, filling username and password, etc, and submit form
		-- Set to 'Personal'	
		do JavaScript "document.forms['loginform']['logintype'].selectedIndex = 1" in doc
		do JavaScript "document.forms['loginform']['go_button'].click()" in doc
		
		-- Submit username
		SafariLib's WaitForFrontWindowToLoad()
		set doc to document "Sign On"
		do JavaScript "document.forms['signon']['userid'].value = 'username'" in doc
		do JavaScript "document.forms['signon'].submit()" in doc
		
		-- Submit password
		SafariLib's WaitForFrontWindowToLoad()
		set doc to document "Sign On"
		do JavaScript "document.forms['loginForm']['Bharosa_Password_PadDataField'].value = 'password'" in doc
		do JavaScript "document.forms['loginForm'].submit()" in doc
		
		SafariLib's WaitForFrontWindowToLoad()
	end tell
end logOntoPrincipalSite
