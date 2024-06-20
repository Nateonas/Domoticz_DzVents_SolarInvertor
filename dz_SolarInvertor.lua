--[[
DZ_SOLARINVERTOR
READ Solar power/energy from invertor and forward to kWhcounter in domoticz
dzVents-scripts for Domoticz
Tested on version Domoticz 2024.4 Raspberry Pi 3 (bullseye)

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

4- Setup -> More options -> User variables
5- Create string variable dz_SolarInvertor, enter username, password and
   IP-address for the invertor:
   Format : username:password@IP-address
   example: larry:kensentme@192.168.0.15

8- Setup -> More options -> Events -> Add automation script -> dzVents -> Minimal
9- Remove the template-text and paste this script
10- Enter the idx of the virtual device in the user defaults below
11- Save as the script as "dzVents_SolarInvertor"


Author  : Nateonas
Date    : 2024-06-20
Version : 4 (ip, username, password in a single user variable & improved error handling)
Source  : initial
Licence : MIT

!! HELP !!
Please inform me when you are changing/improving this dzvents-script.
Better improve the source so everybody can profit than create a personal fork.
https://github.com/Nateonas

]]

--  Customise user defaults        
local kWhcounter_idx =  7281                       -- idx of the virtual device "Electic (Instant+Counter)"

-- No need to change the user defaults below 
local uv_credentials  = 'dz_SolarInvertor'         -- user variable name for username, password and IP-address comma separated
                                                   -- Format : username:password@IP-address
                                                   -- Example: larry:kensentme@192.168.0.15
local scriptVar       = 'SolarYield'               -- name for logging and http-callback, no need to change

return {
	on = {
	    -- No need to fetch data during the night and also the invertor is OFF during the night
	    -- Trannergy only updates once every 5 minutes so no need to set lower than 5 minutes
        timer = { "every 1 minutes between 15 minutes before sunrise and 30 minutes after sunset" },
                -- "every 5 minutes at civildaytime"
        httpResponses = { scriptVar }
    },

    -- The optional logging section allows you to override the global logging setting of dzVents as set in 
    -- Setup > Settings > Other > EventSystem > dzVents Log Level. This can be handy when you only want this 
    -- script to have extensive debug logging while the rest of your script executes silently.

    logging = {
    -- uncomment below to see the debug logging
    --     level = domoticz.LOG_DEBUG,
    --     level = domoticz.LOG_INFO,
            
        -- marker: A string that is prefixed before each log message. That way you can easily create a filter 
        -- in the Domoticz log to see just these messages. marker defaults to scriptname
        marker = scriptVar
    },

    execute = function(domoticz, event)
        
-- easy logging functions
    local function dlog(text) return domoticz.log(text, domoticz.LOG_DEBUG) end -- DEBUG log
    local function ilog(text) return domoticz.log(text, domoticz.LOG_INFO)  end -- INFO log
    local function flog(text) return domoticz.log(text, domoticz.LOG_FORCE) end -- Forced logging (always log regardless of logging setting)
    local function elog(text) return domoticz.log(text, domoticz.LOG_ERROR) end -- Error logging

--  function to split string into an array
        function split(strng, delimiter)
            result = {};
            for match in (strng..delimiter):gmatch("(.-)"..delimiter) do
                table.insert(result, match);
            end
            return result;
        end

-- function dumptable (for debugging)
        local function dumptable(o)
            if type(o) == 'table' then
                local s = '{ '
                    for k,v in pairs(o) do
                        if type(k) ~= 'number' then k = '"'..k..'"' end
                        s = s .. '['..k..'] = ' .. dumptable(v) .. ','
                    end
                return s .. '} '
            else
                return tostring(o)
            end
        end

--  Handle event: Request data from invertor on timer event
        if event.isTimer then
            local credentials  = domoticz.variables(uv_credentials).value
            dlog ( credentials )
            requestURL  = 'http://' .. credentials .. '/js/status.js'
            ilog ( requestURL )
            domoticz.openURL({
                url      = requestURL,
                callback = scriptVar
            })
        end

--  Handle event: Process data in domoticz on response event
        if event.isHTTPResponse then
            if not (event.ok) then
                elog('HTTP response is not ok. HTTP statuscode: ' .. event.statusCode .. ' - ' .. event.statusText .. ' - ' .. event.protocol)
            else
                dlog('data     = ' .. event.data)
                dlog('hasLines = ' .. tostring(event.hasLines))
                dlog('headers  = ' .. dumptable(event.headers))
                dlog('lines    = ' .. dumptable(event.lines))

            -- Desired data is in the part after "myDeviceArray[0]="
            -- e.g. myDeviceArray[0]="PVL4500R81700964,,,,,1106,801,97755,,0,";

                idata = string.match(event.data, 'myDeviceArray%[0%]="(.-)";')
                ilog ( idata )
            
                sdata = split(idata, ",")
                ilog('sdata = ' .. dumptable(sdata))

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
    end
}
