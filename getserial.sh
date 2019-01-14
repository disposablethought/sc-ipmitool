#! /bin/bash

echo "What subnet, 10.64.?"
read thirdoct
echo "Okay so, 10.64.$thirdoct.x - What's the first node? (Ex. 1)"
read startip
echo "What is the last node? (Ex. 96)"
read lastip
(( lastip=$lastip+1 ))
echo "What is the BMC username?"
read user
echo "What is the BMC password?"
read pass

filename="serials-10.64.$thirdoct.$startip-$lastip"
echo ip, mac, serial>> $filename.csv
echo
for (( counter=startip; counter<$lastip; counter++ ))
do
	        ipadd=10.64.$thirdoct.$counter
		        serial=$(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass fru | grep -E "Board Serial          :" | cut -b 26-37)
			        mac=$(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass lan print | grep -E "MAC Address             : " | cut -b 27-43)
						echo "Serial: $serial MAC: $mac"
						        echo $ipadd, $mac, $serial>> $filename.csv


						done


						echo "-----------------------------Complete-----------------------------------"

