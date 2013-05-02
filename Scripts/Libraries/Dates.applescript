(*
Dates Library
v1.0
Dov Frankel, 2013


property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property DatesLib : LibLoader's loadScript("Libraries:Dates.applescript")
*)

-- Returns a Date object for Today at the time specified in timeString
(*
DatesLib's timeOfCurrentDate("12:00 am")
*)
on timeOfCurrentDate(timeString)
	return my timeOfDate(current date, timeString)
end timeOfCurrentDate


-- Returns a Date object for a particular date at the time specified in timeString
(*
DatesLib's timeOfDate("12:00 am")
*)
on timeOfDate(TheDate, timeString)
	return date ((((month of (TheDate) as string) & " " & day of (TheDate) as string) & ", " & year of (TheDate) as string) & " " & timeString)
end timeOfDate

-- Returns true if both dates are either <missing value> or match, disregarding time
(*
DatesLib's datesMatch(dateA, dateB)
*)
on datesMatch(LeftDate, RightDate)
	if LeftDate is missing value then return RightDate is missing value
	if RightDate is missing value then return LeftDate is missing value
	
	return short date string of LeftDate = short date string of RightDate
end datesMatch

-- Adds the specified number of days onto the date without changing its time
(*
DatesLib's addDays(date("1/1/01"), 2)
*)
on addDays(TheDate, NumDays)
	return TheDate + NumDays * days
end addDays

-- Formats the date as mm/dd/yyyy
(*
DatesLib's formatDate(date("1/1/01"))
*)
on formatDate(TheDate)
	-- Get day as 'dd'
	set theDay to (day of TheDate as number) as text
	if theDay's length < 2 then
		set theDay to "0" & theDay
	end if
	
	-- Get month as 'mm'
	set theMonth to (month of TheDate as number) as text
	if theMonth's length < 2 then
		set theMonth to "0" & theMonth
	end if
	
	-- Get year as 'yyyy'
	set theYear to (year of TheDate as number) as text
	
	set dateString to theMonth & "/" & theDay & "/" & theYear
	return dateString
end formatDate