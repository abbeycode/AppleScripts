(*
Uncap Torrents
v1.0
Dov Frankel, 2013
*)

property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")

tell TransmissionLib to ToggleSpeedLimit(false)
