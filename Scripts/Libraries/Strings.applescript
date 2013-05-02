(*
property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
*)

-- Quantity is the count of items, >= 0 (e.g. 5)
-- Singular is the subject's singular (e.g. "query")
-- Plural is the subject's plural (e.g. "queries")
(*
StringsLib's Pluralize(1000, "query", "queries")
*)
on Pluralize(Quantity, Singular, Plural)
	set subject to Plural
	if Quantity = 1 then set subject to Singular
	set message to (Quantity as text) & " " & subject
	
	return message
end Pluralize

-- Trims spaces from beginning and end of someText
(*
StringsLib's Trim("     spaced text  ")
*)
on trim(someText)
	set theseCharacters to ¬
		{" ", tab, ASCII character 10, return, ASCII character 0}
	
	--log "Trimming text: " & someText
	repeat until first character of someText is not in theseCharacters
		set someText to text 2 thru -1 of someText
	end repeat
	
	repeat until last character of someText is not in theseCharacters
		set someText to text 1 thru -2 of someText
	end repeat
	
	return someText
end trim

-- Splits out the string into its component parts
(*
StringsLib's Split(":", "a:b:c")
*)
on split(delimiter, someText)
	set prevTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set output to text items of (someText as string)
	set AppleScript's text item delimiters to prevTIDs
	return output
end split

-- Replaces a substring with another substring
(*
StringsLib's replace_text(some_text, "abc", "def")
*)
on replace_text(this_text, search_string, replacement_string)
	set prevTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to prevTIDs
	return this_text
end replace_text