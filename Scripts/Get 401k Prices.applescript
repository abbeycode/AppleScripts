(*
Get 401k Prices
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Logs into the Principal financial website, and gets contribution and share price information, copying them to the clipboard

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")


set principalSharePrice to my getPrincipalSharePrice()
set principalContributions to my getPrincipalContributions()

set outMessage to "401k Price
Principal 401(k)   " & principalSharePrice's shareDate & "   " & principalSharePrice's sharePrice & "

" & principalContributions

-- Log out, to make it easier to run the script multiple times in a shorter window
SafariLib's LoadUrlInFrontWindow("https://secure05.principal.com/https.secure05/shared/members/corp/LogoutServlet")

-- All done with the window, close it	
tell SafariLib to CloseWindow()

--set the clipboard to (outMessage as Unicode text)
return (outMessage as Unicode text)


-----------------------------------------------------------------------------
on getPrincipalSharePrice()
	tell application "Safari"
		SafariLib's LoadUrlInNewWindow("http://www.principal.com/InvestmentProfiles/performance.faces?inv=4568&rtclss=68&retail=false")
		
		set doc to document "Principal LifeTime 2050 Separate Account-I3"
		set frameURL to (do JavaScript "document.getElementById('QSAPI_IFRAME_0').getAttribute('src')" in doc) as text
		
		SafariLib's LoadUrlInFrontWindow(frameURL)
		
		set doc to document "Chart"
		do JavaScript "document.getElementsByClassName('qs-urlchart-export')[0].click()" in doc
		delay 5
	end tell
	
	-- All done with the window, close it	
	tell SafariLib to CloseWindow()
	
	tell application "Finder"
		set xlsFilePath to POSIX path of ((path to downloads folder as text) & "MarketPrice.xls")
		
		set theTryNumber to 1
		
		repeat until exists xlsFilePath as POSIX file
			delay 0.5
			
			if theTryNumber = 60 then
				display dialog "Error getting " & xlsFilePath
				return 0
			end if
			
			set theTryNumber to theTryNumber + 1
		end repeat
	end tell
	
	-- Convert XLS to CSV
	set xlsFilePath to POSIX path of ((path to downloads folder as text) & "MarketPrice.xls")
	set xlsFile to POSIX file (xlsFilePath as text)
	
	tell application "Numbers"
		open xlsFile
		
		set dateValue to missing value
		set priceValue to missing value
		set rowNumber to 366
		
		set xlsDoc to document "MarketPrice"
		repeat while dateValue is missing value and priceValue is missing value
			try
				set dateCell to "A" & rowNumber
				set priceCell to "B" & rowNumber
				set dateValue to (value of cell dateCell of table 1 of sheet 1 of xlsDoc as text)
				set priceValue to (value of cell priceCell of table 1 of sheet 1 of xlsDoc as text)
			on error err
				log err
				log "There is no row " & rowNumber & ". Trying row " & rowNumber - 1
				set rowNumber to rowNumber - 1
			end try
		end repeat
		close xlsDoc saving no
	end tell
	
	tell application "Finder" to move xlsFile to trash
	
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
		
		set doc to document "Principal.com: Investment Management, Retirement, and Insurance"
		
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
