(*
Get Sallie Mae Loan Splits
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Logs into the Sallie Mae website, and totals up the Principal and Interest amounts by month for each category of loan listed

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")

property AccountInfo : {¬
	{label:"Dov", username:"dov_username", password:"dov_password"}, ¬
	{label:"Christine", username:"christine_username", password:"christine_password"} ¬
		}

-- Initialize output
set outMessage to "Sallie Mae principal/interest splits"

-- Loop through each account, getting their outputs, appending to main
repeat with account in AccountInfo
	my logOntoSallieMaeSite(account's username, account's password)
	set theAccountSplits to my getSplitsForAccount()
	
	set outMessage to outMessage & "
" & account's label
	repeat with accountSplit in theAccountSplits
		set split to accountSplit's split
		set totalAmount to (split's principal) + (split's interest)
		set outMessage to outMessage & "
" & accountSplit's accountName & "(" & split's |date| & ", $" & totalAmount & ") – Principal: $" & split's principal & "	Interest: $" & split's interest
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
on getSplitsForAccount()
	tell application "Safari"
		set doc to front document
		
		-- Get all "Transaction History" links, pulled only from the top navigation area
		set linkScripts to do JavaScript "
		function returnValue() {
			var linkSelector = \"a:contains('Transaction history')\";
			var transactionHistoryLinks = $(linkSelector).filter('[href*=\"TopNav\"]');
			var linkScripts = [];
			transactionHistoryLinks.each(function() {
				var linkScript = $(this).attr('href').replace('javascript:', '');
				var linkName = linkScript.match(/\\('(\\w+)',/);
				linkScripts.push({
					script: linkScript,
					name: linkName[1]
				});
			});
			
			console.log(linkScripts);
			return linkScripts;
		}
		
		returnValue();
		" in doc
		
		set theSplits to {}
		
		-- Loop through each history, retrieving the payment data
		repeat with link in linkScripts
			set doc to front document
			set split to {accountName:link's |name|, split:my getSplitForPage(link's |script|, doc)}
			copy split to the end of theSplits
		end repeat
		
		return theSplits
	end tell
end getSplitsForAccount

on getSplitForPage(linkScript, doc)
	tell application "Safari"
		do JavaScript "eval(\"" & linkScript & "\")" in doc
		delay 3
		
		SafariLib's WaitForFrontWindowToLoad()
		set doc to document "Sallie Mae - Financial Transaction History"
		
		set payments to do JavaScript "
			function returnValue() {
				payments = [];
				
				$('tr.datagray').add('tr.datawhite').each(function() {
					console.log($(this));
					payments.push({
						date: $(this).find(':nth-child(2)').text(),
						principal: parseFloat($(this).find(':nth-child(8)').text().replace('$ ', '')),
						interest: parseFloat ($(this).find(':nth-child(10)').text().replace('$ ', ''))
					});
					
				});
				
				return payments;
			}
			
			returnValue();
			" in doc
		
		set transactionDate to ""
		set totalPrincipal to 0
		set totalInterest to 0
		
		repeat with payment in payments
			if transactionDate is not "" and transactionDate ≠ payment's |date| then exit repeat
			
			set transactionDate to payment's |date|
			
			-- Quantities are expressed as negative numbers
			set totalPrincipal to totalPrincipal - (payment's principal)
			set totalInterest to totalInterest - (payment's interest)
		end repeat
		
		return {|date|:transactionDate, principal:totalPrincipal, interest:totalInterest}
	end tell
end getSplitForPage

on logOntoSallieMaeSite(username, |password|)
	tell application "Safari"
		-- Load a new window for the Sallie Mae site
		set loginURL to "https://login.salliemae.com/CALM/calm.do?sourceAppName=SLMACOM"
		SafariLib's LoadUrlInNewWindow(loginURL)
		
		-- Get around occasional redirect
		SafariLib's CloseWindow()
		SafariLib's LoadUrlInNewWindow(loginURL)
		
		activate
		delay 2
		
		set doc to document "Log into your loan account"
		
		-- Log in, filling username and password, and submit form
		do JavaScript "document.forms['LoginForm']['UserID'].value = '" & username & "'" in doc
		do JavaScript "document.forms['LoginForm']['Password'].value = '" & |password| & "'" in doc
		do JavaScript "document.forms['LoginForm'].submit()" in doc
		
		SafariLib's WaitForFrontWindowToLoadIgnoringUrlContainingString(loginURL, "loanSummary")
	end tell
end logOntoSallieMaeSite