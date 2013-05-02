(*
property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property GrowlLib : LibLoader's loadScript("Libraries:Growl.applescript")

tell GrowlLib to Notify("Some sample message")
*)

property allNotificationsList : {"Script"}
property enabledNotificationsList : {"Script"}

on Register()
	tell application "Growl" to register as application "Script" all notifications allNotificationsList default notifications enabledNotificationsList icon of application "AppleScript Editor"
end Register

--Notify that an action has been performed
on Notify(NotifyText)
	tell application "Growl"
		notify with name "Script" title "Script" description NotifyText application name "Script" with sticky
	end tell
end Notify

--Notify that an action has been performed
on NotifyNonsticky(NotifyText)
	tell application "Growl"
		notify with name "Script" title "Script" description NotifyText application name "Script"
	end tell
end NotifyNonsticky