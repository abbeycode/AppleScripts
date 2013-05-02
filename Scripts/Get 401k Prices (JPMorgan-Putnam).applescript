property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

-- Turn Speed Limit on
tell TransmissionLib to initialize()
tell TransmissionLib to ToggleSpeedLimit(true)


my LogIntoJPRetirement("username", "password")
set jpmPrice to my ScrapeChasePrices("Target Date 2050 Fund", 141356)
set rbsPrice to my ScrapeChasePrices("JPMCB SmartRetirement 2050-C20", 159907)

-- All done with the window, close it	
tell SafariLib to CloseWindow()

delay 5

--set sgContribution to my Get401kContribution()

set outMessage to "401k Prices
JPMorgan SmartRetire 2050 (RBS)	– " & rbsPrice & "
Target Date 2050 Fund (JPM)		– " & jpmPrice & "

SG Contribution
" -- & sgContribution

-- Open up text window for copy/paste of results
tell application "TextEdit"
	activate
	set doc to make new document
	set doc's text to outMessage
end tell


tell GrowlLib to NotifyNonsticky("401k share prices downloaded")
tell TransmissionLib to Finalize()


on LogIntoJPRetirement(theUsername, thePassword)
	-- Load a new window for the RetireOnline site
	SafariLib's LoadUrlInNewWindow("https://www.retireonline.com")
	
	tell application "Safari"
		activate
		delay 2
		set doc to document "Retireonline - J.P. Morgan Retirement Plan Services"
		set loginUrl to doc's URL
		
		-- Fill in username and password, and submit form	
		do JavaScript "document.forms['signonForm']['USER'].value = '" & theUsername & "'" in doc
		do JavaScript "document.forms['signonForm']['PASSWORD'].value = '" & thePassword & "'" in doc
		do JavaScript "document.forms['signonForm'].submit()" in doc
	end tell -- Safari
	
	SafariLib's WaitForFrontWindowToLoadIgnoringUrlContainingString(loginUrl, "TotalBalance")
end LogIntoJPRetirement

on ScrapeChasePrices(fundName, planNumber)
	SafariLib's LoadUrlInFrontWindow("https://www.retireonline.com/rpsparticipant/RedirectToTejasController?tejasController=fundPerformance.do&PlanNo=" & planNumber & "")
	SafariLib's LoadUrlInFrontWindow("https://www.retireonline.com/rpsparticipant/fundPriceInfo.do")
	
	tell application "Safari"
		set doc to document "Fund Information - Prices - J.P. Morgan Retirement Plan Services"
		
		-- Pull out and open the link for the target fund
		set docSource to doc's source as text
		set fundUrlEx to re_compile "javascript:.*Price.*'" & fundName & ".*\\)"
		set fundPriceAction to find text fundUrlEx in docSource with regexp and string result
		do JavaScript fundPriceAction in doc
		
		delay 5
		
		-- Set a 5-day date period
		do JavaScript "document.forms['fundPriceHistoryCriteria']['date_period'].value = -5" in doc
		
		-- Submit the price list query
		do JavaScript "document.getElementsByName('continueButton')[0].click()" in doc
		
		delay 5
		
		-- Pull out the dates and prices
		set docSource to doc's source as text
	end tell
	
	set datesEx to re_compile "<td class=\"infodata(?:shaded)?\">([0-9/]+)</td>"
	set theDates to find text datesEx in docSource using "\\1" with regexp, all occurrences and string result
	
	-- Pull out the prices
	set pricesEx to re_compile "<td class=\"infodata(?:shaded)? right_align\">([0-9\\.$]+)</td>"
	set thePrices to find text pricesEx in docSource using "\\1" with regexp, all occurrences and string result
	
	-- Get a mm/dd/yyyy string of the target date
	set pricingDate to DatesLib's addDays(current date, -2)
	set pricingDateStr to DatesLib's formatDate(pricingDate)
	
	-- Find the price for that date
	repeat with n from 1 to length of theDates
		set nDate to item n of theDates
		
		-- If the row is for the target date, return it
		if nDate is equal to pricingDateStr then
			return nDate & ": " & item n of thePrices
		end if
	end repeat
	
	return "date not found"
end ScrapeChasePrices

on Get401kContribution()
	tell application "Safari"
		SafariLib's LoadUrlInNewWindow("https://www.putnam.com/401k")
		activate
		delay 5
		set doc to document "401(k) Participant Login - Putnam Investments"
		set loginUrl to doc's URL
		
		-- Fill in username and password, and submit form
		do JavaScript "var loginForm = document.getElementById('loginContentFrame').contentDocument.forms['login']" in doc
		do JavaScript "loginForm['SSN'].value = 'username'" in doc
		do JavaScript "loginForm['PIN'].value = 'PIN'" in doc
		do JavaScript "loginForm.submit()" in doc
		
		-- Once main page loads, navigate to "History & Statements"
		SafariLib's WaitForFrontWindowToLoadIgnoringUrlContainingString(loginUrl, "Main.htm")
		set doc to document "Putnam Investments"
		do JavaScript "$('#four01kPanel .viewFull.viewDetails').click()" in doc
		do JavaScript "$('a[href=\"#NODE5\"]').click()" in doc
		
		-- Open the Statements On Demand page
		SafariLib's LoadUrlInFrontWindow("https://fascore.putnam.com/statementsOnDemand.do?nodeId=3757&accu=PutnamSales")
		set doc to document "Putnam Retirement Solutions Web site"
		do JavaScript "eval($('#statementsByMoneyTypeTable a:first').attr('href'))" in doc
		
		-- Get the HTML of the results page
		delay 3
		set doc to front document
		set docSource to doc's source as text
	end tell -- Safari
	
	-- Pull out first date
	set effDateEx to re_compile "<td[[:space:]]+class=\"effdate (?:even|odd)\"[[:space:]]+id=\"statementsByTxnDetailEffdate\">([0-9/]+)</td>"
	set effDate to find text effDateEx in docSource using "\\1" with regexp and string result
	
	-- Pull out first Amount
	set amountEx to re_compile "<td[[:space:]]+class=\"dollarAmount (?:even|odd)\"[[:space:]]+id=\"statementsByTxnDetailAmount\">([$0-9\\.]+)</td>"
	set amount to find text amountEx in docSource using "\\1" with regexp and string result
	
	-- Pull out first share count
	set sharesEx to re_compile "<td[[:space:]]+class=\"number (?:even|odd)\"[[:space:]]+id=\"statementsByTxnDetailUnitShares\">([0-9\\.]+)</td>"
	set shares to find text sharesEx in docSource using "\\1" with regexp and string result
	
	-- Close windows
	tell SafariLib to CloseWindow()
	tell SafariLib to CloseWindow()
	
	return "Purchased " & shares & " shares for " & amount & " on " & effDate & "
(price per share: " & amount & "/" & shares & ")"
end Get401kContribution