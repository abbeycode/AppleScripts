(*
Uncap Torrents
v1.0
Dov Frankel, 2013
http://dovfrankel.com

Uncaps Transmission (turns of "turtle mode").

Useful when activated by a mail rule, to perform the action remotely, or a calendar event, to uncap them before bed time, in case you forgot

*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")

tell TransmissionLib to ToggleSpeedLimit(false)
