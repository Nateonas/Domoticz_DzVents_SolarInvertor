--[[
READ Solar power/energy from invertor and forward to kWhcounter in domoticz

This script will work with Ginlong, Omnik Solar, Solarman and Trannergy Inverters
that have a response to http://<invertor-ip-address>/js/status.js
Check this URL in your browser to see if your invertor responds to this address
Response must include "myDeviceArray[0]" in the first line after "var version".
Please note that the invertor shuts itself down during the night, so you cannot
connect to the invertor-ip during that time.

If you have a status.js, then you can add this dzVents-script to Domoticz:
1- Create a virtual device "Electic (Instant+Counter)" in Domoticz
2- Edit properties, change type from "Usage" to "Return"
3- Write down the idx

4- Setup -> More options -> Events -> Add automation script -> dzVents -> Minimal
5- Remove the template-text and paste this script
6- update ip, user, pw and idx (no need to change scriptVar)
7- Save as the script as "dzVents_SolarInvertor"

Author  : Nateonas
Date    : 2024-05-24
Version : 2 (added easy logging)
Source  : initial

!! HELP !!
Please inform me when you are changing/improving this dzvents-script.
Better improve the source so everybody can profit than create a personal fork.
https://github.com/Nateonas

]]

--  Customise user defaults        
local ip               = '127.0.0.1'  -- ip address of the solar inverter webinterface
local user             = 'username'      -- user name for solar inverter webinterface
local pw               = 'password'      -- password for solar inverter webinterface
local kWhcounter_idx   =  0           -- idx of the virtual device "Electic (Instant+Counter)"
local scriptVar        = 'SolarYield'    -- name for logging and http-callback, no need to change

return {
	on = {
	    -- No need to fetch data during the night and also the invertor is OFF during the night
	    -- Trannergy only updates once every 5 minutes so no need to set lower than 5 minutes
        timer = { "every 5 minutes between 30 minutes before sunrise and 30 minutes after sunset" },
        httpResponses = { scriptVar }
    },

    -- The optional logging section allows you to override the global logging setting of dzVents as set in 
    -- Setup > Settings > Other > EventSystem > dzVents Log Level. This can be handy when you only want this 
    -- script to have extensive debug logging while the rest of your script executes silently.

    logging = {
    -- uncomment below to see the debug logging
        -- level = domoticz.LOG_DEBUG,

        -- marker: A string that is prefixed before each log message. That way you can easily create a filter 
        -- in the Domoticz log to see just these messages. marker defaults to scriptname
        marker = scriptVar
    },

    execute = function(domoticz, event)
-- easy logging functions
    local function dlog(text) return domoticz.log(text, domoticz.LOG_DEBUG) end -- DEBUG log
    local function ilog(text) return domoticz.log(text, domoticz.LOG_INFO)  end -- INFO log
    local function flog(text) return domoticz.log(text, domoticz.LOG_FORCE) end -- Forced logging (always log regardless of logging setting)

--  function to split string into an array
        function split(strng, delimiter)
            result = {};
            for match in (strng..delimiter):gmatch("(.-)"..delimiter) do
                table.insert(result, match);
            end
            return result;
        end

--  Handle event: Request data from invertor on timer event
        if event.isTimer then
            requestURL = 'http://'..user..':'..pw..'@'..ip..'/js/status.js'
            domoticz.openURL({
                url = requestURL,
                callback = scriptVar
            })
        end

--  Handle event: Process data in domoticz on response event
--        if (event.isHTTPResponse and event.ok and (event.trigger == scriptVar)) then
        if event.isHTTPResponse then
            dlog(event.data)

            -- Desired data is in the part after "myDeviceArray[0]="
            -- e.g. myDeviceArray[0]="PVL4500R81700964,,,,,1106,801,97755,,0,";
            --                                             ^^^^^^^^^^^^^^
            idata = string.match(event.data, 'myDeviceArray%[0%]="(.-)";')
            dlog ( idata )
            
            sdata = split(idata, ",")
            for key, value in pairs(sdata) do
                dlog( key..'='..value )
            end

            powerW = sdata[6]     -- Current power in W
            etoday = sdata[7]/100 -- Daily yield in kWh
            etotal = sdata[8]/10  -- Total yield in kWh
                
--  Update kWhcounter in Domoticz
            -- Domoticz shows daily increments of the total energy, so update with TOTAL, not daily.
            -- This could mean that on creating a new device all previous energy seems generated on the
            -- first day. Daily increments will return to normal from the second day.
            -- increment in W, counter in Wh
            domoticz.devices(kWhcounter_idx).updateElectricity(powerW, etotal*1000)

            flog ( "Power: "..powerW.." W | Today: "..etoday.." kWh | Total: "..etotal.." kWh" )
        end
    end
}
