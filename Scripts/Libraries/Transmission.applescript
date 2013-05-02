(*
property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
property TransmissionLib : LibLoader's loadScript("Libraries:Transmission.applescript")

tell TransmissionLib to Initialize()
tell TransmissionLib to ToggleSpeedLimit(true)
tell TransmissionLib to Finalize()
*)

-- Remember if Transmission's Speed Limit was on before the script ran
global speedLimitWasPreviouslyOn

property toggleEnabledDelay : 15
property delayOn : true


-- Should be the first call a script that uses this library makes
on initialize()
	set speedLimitWasPreviouslyOn to my SpeedLimitIsOn()
	set delayOn to true
end initialize

-- Should be the last call a script that uses this library makes
on Finalize()
	my ToggleSpeedLimit(speedLimitWasPreviouslyOn)
	set delayOn to true
end Finalize

-- Used during testing to eliminate waiting. Turned back on in Finalize().
on TurnDelayOff()
	set delayOn to false
end TurnDelayOff

-- Turns Speed Limit on or off, depending on the SpeedLimitOn parameter
on ToggleSpeedLimit(SpeedLimitOn)
	if not TransmissionIsRunning() then return
	
	-- Sometimes necessary (who knows why)
	set SpeedLimitOn to SpeedLimitOn as boolean
	
	tell application "Transmission" to activate
	
	tell application "System Events"
		tell process "Transmission"
			-- If the limit isn't already set to what it should be, toggle it
			if SpeedLimitOn ≠ my SpeedLimitIsOn() then
				click menu item "Speed Limit" of menu "Transfers" of menu bar 1
				
				-- If it was just toggled on, wait for it to kick in before returning
				if SpeedLimitOn and delayOn then
					delay toggleEnabledDelay
				end if
			end if
		end tell
	end tell
end ToggleSpeedLimit

on SpeedLimitIsOn()
	if not TransmissionIsRunning() then return no
	
	tell application "Transmission" to activate
	
	tell application "System Events"
		tell process "Transmission"
			return (value of attribute "AXMenuItemMarkChar" of menu item "Speed Limit" of menu "Transfers" of menu bar 1 as string) ≠ ""
		end tell
	end tell
end SpeedLimitIsOn

on TransmissionIsRunning()
	
	tell application "System Events"
		return (name of processes) contains "Transmission"
	end tell
	
end TransmissionIsRunning