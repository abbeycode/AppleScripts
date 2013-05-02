(*
Safari Library
v1.0
Dov Frankel, 2013


property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property SafariLib : LibLoader's loadScript("Libraries:Safari.applescript")
*)

-- Test
--my LoadUrlInNewWindow("http://chaseonline.chase.com")

(*
tell SafariLib to CloseWindow()
*)
on CloseWindow()
	tell application "Safari" to activate
	tell application "System Events"
		tell process "Safari"
			click menu item "Close Window" of menu "File" of menu bar 1
		end tell
	end tell
end CloseWindow

(*
tell SafariLib to LoadUrlInFrontWindow( "http://www..." )
*)
on LoadUrlInFrontWindow(theUrl)
	tell application "Safari"
		activate
		delay 0.5
		set theDoc to front document
		
		set theOldUrl to ""
		set theOldUrl to theDoc's URL
		
		if theOldUrl = null then set theOldUrl to ""
		
		set theDoc's URL to theUrl
		my WaitForFrontWindowToLoadIgnoringUrlContainingString(theOldUrl, ":")
	end tell
end LoadUrlInFrontWindow

(*
tell SafariLib to LoadUrlInNewWindow( "http://www..." )
*)
on LoadUrlInNewWindow(theUrl)
	tell application "Safari"
		make new document
		activate
	end tell
	my LoadUrlInFrontWindow(theUrl)
end LoadUrlInNewWindow

(*
tell SafariLib to WaitForFrontWindowToLoadIgnoringUrl()
*)
on WaitForFrontWindowToLoadIgnoringUrlContainingString(OldUrl, UrlStr)
	set maxAttempts to 15
	
	tell application "Safari"
		repeat
			my WaitForFrontWindowToLoad()
			set theUrl to front document's URL
			set correctPageLoaded to theUrl ≠ OldUrl and theUrl contains UrlStr
			log "Old URL:
" & OldUrl & "
New URL:
" & theUrl & "
URL String:
" & UrlStr
			log "Correct page is loaded: " & correctPageLoaded
			set maxAttempts to maxAttempts - 1
			if correctPageLoaded or maxAttempts = 0 then exit repeat
		end repeat
	end tell
end WaitForFrontWindowToLoadIgnoringUrlContainingString

(*
tell SafariLib to WaitForFrontWindowToLoad()
*)
on WaitForFrontWindowToLoad()
	tell application "Safari"
		activate
		
		set maxAttempts to 15
		
		set doneLoading to false
		repeat until doneLoading = true or maxAttempts = 0
			delay 3
			set theDoc to front document
			set maxAttempts to maxAttempts - 1
			set doneLoading to ((do JavaScript "document.readyState" in theDoc) is "complete") ¬
				and theDoc's URL does not start with "topsites"
			
			set maxAttempts to maxAttempts - 1
		end repeat
		
		log "done loading: " & theDoc's URL
	end tell
end WaitForFrontWindowToLoad