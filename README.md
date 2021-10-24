# Domoticz_DzVents_SolarInvertor
READ Solar power/energy from Ginlong, Omnik Solar, Solarman and Trannergy Invertors forward to kWhcounter in domoticz 

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
