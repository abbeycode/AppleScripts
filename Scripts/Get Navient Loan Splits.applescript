(*
Get Navient Loan Splits
v1.1
Dov Frankel, 2013
http://dovfrankel.com

Logs into the Navient website, and totals up the Principal and Interest amounts by month for each category of loan listed

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

property AccountInfo : {¬
	{label:"Dov", username:"dov_username", password:"dov_password"}, ¬
	{label:"Christine", username:"christine_username", password:"christine_password"} ¬
		}


if (day of (current date)) as number < 20 then return "Too early for this month to retrieve new loan splits"


-- Initialize output
set outMessage to "Navient principal/interest splits"

-- Loop through each account, getting their outputs, appending to main
repeat with account in AccountInfo
	my logOntoNavientSite(account's username, account's password)
	set theAccountSplits to my getSplitsForAccount(account's username)
	
	set outMessage to outMessage & "
" & account's label
	repeat with accountSplit in theAccountSplits
		log accountSplit
		set totalAmount to (accountSplit's principal) + (accountSplit's interest)
		set outMessage to outMessage & "
(" & accountSplit's |date| & ", $" & totalAmount & ") – Principal: $" & accountSplit's principal & "	Interest: $" & accountSplit's interest
	end repeat
	
	
	set outMessage to outMessage & "
"
	
	tell SafariLib to CloseWindow()
end repeat

-- Return output
--set the clipboard to (outMessage as Unicode text)
log outMessage
return (outMessage as Unicode text)


-----------------------------------------------------------------------------

on getSplitsForAccount(username)
	SafariLib's LoadUrlInFrontWindow("https://myaccount.navient.com/AccountHistory/ViewHistory")
	
	tell application "Safari"
		set doc to document "Navient | Account History"
		
		set theSplits to {}
		
		set payments to do JavaScript "
			function returnValue() {
				payments = [];
				
				$('tr:has(td[title=\"Payment\"])').each(function() {
					//console.log($(this));
					payments.push({
						date: $(this).children(':nth-child(1)').text().trim(),
						principal: parseFloat($(this).children(':nth-child(3)').attr('title')),
						interest: parseFloat($(this).children(':nth-child(4)').attr('title'))
					});
					
				});
				
				return payments;
			}
			
			returnValue();
			" in doc
	end tell
	
	set paymentMonth to null
	
	repeat with payment in payments
		set paymentDate to payment's |date|
		set currentPaymentMonth to month of date paymentDate
		
		if paymentMonth is not null and paymentMonth ≠ currentPaymentMonth then exit repeat
		
		set paymentMonth to currentPaymentMonth
		
		-- Payments are expressed as negative numbers
		set totalPrincipal to -1 * (payment's principal)
		set totalInterest to -1 * (payment's interest)
		
		set theSplit to {|date|:paymentDate, principal:totalPrincipal, interest:totalInterest}
		copy theSplit to the end of theSplits
	end repeat
	
	return theSplits
	
end getSplitsForAccount

on logOntoNavientSite(username, |password|)
	tell application "Safari"
		-- Load a new window for the Navient site
		set loginURL to "https://login.navient.com/CALM/calm.do?sourceAppName=NAVCOM"
		SafariLib's LoadUrlInNewWindow(loginURL)
		
		activate
		
		set doc to document "Log into your loan account"
		
		-- Log in, filling username and password, and submit form
		do JavaScript "document.forms['LoginForm']['UserID'].value = '" & username & "'" in doc
		do JavaScript "document.forms['LoginForm']['Password'].value = '" & |password| & "'" in doc
		do JavaScript "document.forms['LoginForm'].submit()" in doc
		
		delay 2
		
		SafariLib's WaitForFrontWindowToLoadIgnoringUrlContainingString(loginURL, "AccountSummary")
	end tell
end logOntoNavientSite