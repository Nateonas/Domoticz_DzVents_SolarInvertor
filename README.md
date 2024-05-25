# Domoticz_DzVents_SolarInvertor
READ Solar power/energy from invertor and forward to kWhcounter in domoticz
dzVents-scripts for Domoticz
Tested on version Domoticz 2024.4 Raspberry Pi 3 (bullseye) 

<strong>This script will work with Ginlong, Omnik Solar, Solarman and Trannergy Inverters that have a response to<br>http://invertor-ip-address/js/status.js</strong>

Check this URL in your browser to see if your invertor responds to this address. Response must include "myDeviceArray[0]" in the first line after "var version".

Please note that the invertor can shut itself down during the night, so you cannot connect to the invertor-ip during that time.<br>

If you have a status.js, then you can add this dzVents-script to Domoticz:<br>
1- Create a virtual device "Electic (Instant+Counter)" in Domoticz<br>
2- Edit properties, change type from "Usage" to "Return"<br>
3- Write down the idx<br><br>

4-  Setup -> More options -> User variables<br>
5- Create string variable dz_SolarInvertor_username, enter username for the invertor<br>
6- Create string variable dz_SolarInvertor_password, enter username for the invertor<br>
7- Create string variable dz_SolarInvertor_IP, enter IP-address for the invertor<br><br>

8- Setup -> More options -> Events -> Add automation script -> dzVents -> Minimal<br>
9- Remove the template-text and paste this script<br>
10- Enter the idx of the virtual device in the user defaults below<br>
11- Save as the script as "dzVents_SolarInvertor"<br><br>

!! HELP !!<br>
Please log an issue or push an update when you are changing/improving this dzvents-script. Better improve the source so everybody can profit than create a personal fork. <br>
(https://github.com/Nateonas/Domoticz_DzVents_SolarInvertor)

