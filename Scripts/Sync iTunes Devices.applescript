(*
Sync iTunes Devices
v1.0
Dov Frankel, 2013
http://dovfrankel.com

I haven't used this one in a while, but it syncs all "iPods" and Apple TVs with iTunes.

It uses UI scripting to accomplish the AppleTV syncing portion

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")
property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")
property iTunesLib : LibLoader's loadScript("Libraries:iTunes.applescript")

--property AppleTvNames : {"Greedo", "Sy Snootles"}

-- Possible bug fix...
tell application "iTunes" to activate

--Update all stale podcasts
run script POSIX file "/Users/Dov/Library/iTunes/Scripts/Update Expired Podcasts.scpt"

-- Sync the Apple TV first, since it uses GUI scripting, and is prone to failure, which causes problems when syncing the iPods first as they hang, draining the iPad's battery
set appleTVsSynced to 0
-- Sync all AppleTVs
repeat with aTv in AppleTvNames
	log ("Attempting to sync " & aTv)
	set syncSuccess to iTunesLib's SyncAppleTv(aTv)
	log ("Success: " & syncSuccess)
	if syncSuccess then
		set appleTVsSynced to appleTVsSynced + 1
	end if
end repeat

-- Sync the iPods after the AppleTVs have finished syncing

tell application "iTunes"
	-- wait 10 minutes for any podcasts to finish downloading
	delay 600
	
	set iPodsSynced to 0
	-- Sync all iPods
	repeat with s in sources
		--display dialog "Source: " & s's name
		if (kind of s is iPod) then
			update s
			set iPodsSynced to iPodsSynced + 1
		end if
	end repeat
end tell

-- No more UI scripting, since Apple TVs are no longer synced
tell iTunesLib to SelectSource("Music")

tell GrowlLib to NotifyNonsticky("Synced " & StringsLib's Pluralize(iPodsSynced, "iPod", "iPods" & ", " & StringsLib's Pluralize(appleTVsSynced, "tv", "tv's")))
