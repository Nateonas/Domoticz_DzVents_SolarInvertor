# Domoticz_DzVents_SolarInvertor
READ Solar power/energy from Ginlong, Omnik Solar, Solarman and Trannergy Invertors forward to kWhcounter in domoticz 

<strong>This script will work with Ginlong, Omnik Solar, Solarman and Trannergy Inverters that have a response to<br>http://invertor-ip-address/js/status.js</strong>

Check this URL in your browser to see if your invertor responds to this address. Response must include "myDeviceArray[0]" in the first line after "var version".

Please note that the invertor can shut itself down during the night, so you cannot connect to the invertor-ip during that time.

If you have a status.js, then you can add this dzVents-script to Domoticz:<br>
1- Create a virtual device "Electic (Instant+Counter)" in Domoticz<br>
2- Edit properties, change type from "Usage" to "Return"<br>
3- Write down the idx<br><br>
4- Setup -> More options -> Events -> Add automation script -> dzVents -> Minimal<br>
5- Remove the template-text and paste the text from dz_SolarInvertor.lua<br>
6- update ip, user, pw and idx (no need to change scriptVar)<br>
7- Save as the script as "dzVents_SolarInvertor"<br><br>
(8- Temporarily uncomment the debug loglevel to see the full logging in the domoticz-log)<br>
