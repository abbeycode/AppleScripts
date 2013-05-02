-- Get URL from Safari
tell application "Safari"
	set safariURL to URL of front document
end tell

-- Open URL in Chrome
tell application "Google Chrome"
	-- Open Chrome, or bring it to the front if it's already open
	activate
	
	-- Get the front window
	set theWindow to first window
	
	-- Get the selected tab in the window
	set theTab to active tab of theWindow
	
	-- If that window isn't pointing to your home page, then open a new tab
	if theTab's URL ≠ "http://www.google.com/" and theTab's URL ≠ "chrome://newtab/" then
		tell theWindow to make new tab
		set theTab to active tab of theWindow
	end if
	
	-- Open the URL in Chrome
	set URL of theTab to safariURL
end tell