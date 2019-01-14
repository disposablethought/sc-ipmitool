#!/bin/bash
title="StudioCloud IPMItool Automation"
prompt="Pick an option:"
options=("Power on/off" "UID on/off" "Power Cycle" "Set VLAN" "Change IP" "Set Netmask" "Set Netmask" "Set Gateway" "Change Username" "Change Password" "Clear SEL Logs")

echo "Welcome to StudioCloud's IPMItool Automator"
echo "What is the subnet we are working on, 10.64.?"
read thirdoct
echo "Okay so, 10.64.$thirdoct.x - What's the first node's IP? (Ex. 1)"
read startip
echo "What is the last node IP? (Ex. 96)"
read lastip
(( lastip=$lastip+1 ))
echo "What is the BMC username?"
read user
echo "What is the BMC password?"
read pass


echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do 

	    case "$REPLY" in

    1 ) echo "Power On or Off? [Enter 'on' or 'off' parameters only]"
	    read power
	    for (( counter=startip; counter<$lastip; counter++ ))
		   	 do
		            ipadd=10.64.$thirdoct.$counter
			    echo "Powering $power $ipadd"
		            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass power $power)
			 done
		    	 echo "-----------------------------Complete-----------------------------------"
		   ;;
    2 ) echo "UID time on amount? [Enter number, ex '1' for 1 second, or enter 'force' to stay on]"
 	echo "Note: Entering '1' for one second is how you get it to turn off"
	    read timer
	    for (( counter=startip; counter<$lastip; counter++ ))
		         do
			    ipadd=10.64.$thirdoct.$counter
			    echo "Setting UID for $ipadd"
			    $( /usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass chassis identify $timer )
			 done
			 echo "-----------------------------Complete-----------------------------------"
	           ;;
    3 )     for (( counter=startip; counter<$lastip; counter++ ))
	                 do
			    ipadd=10.64.$thirdoct.$counter
			    echo "Restarting $ipadd"
			    $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass chassis power cycle)
			 done
			 echo "-----------------------------Complete-----------------------------------"
	           ;;
    4 ) echo "Enter desired VLAN: (Enter 'off' to disable)"
	read vlan
	    for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=10.64.$thirdoct.$counter
			    echo "Setting $ipadd to VLAN $vlan"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 0x01 vlan id $vlan)
                         done
                         echo "-----------------------------Complete-----------------------------------"
		  	;;
    5 ) echo "Enter new subnet for IPs: (Ex. enter '115' to change 10.64.?.x to 10.64.115.x)"
			read newsub
	    for (( counter=startip; counter<$lastip; counter++ ))
	                 do
			    ipadd=10.64.$thirdoct.$counter
			    echo "Changing $ipadd to 10.64.$newsub.$counter"
			    $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 ipaddr 10.64.$newsub.$counter &) &
			 done;
			 echo "-----------------------------Complete-----------------------------------"
			;;
   6 ) echo "Please enter desired netmask:"
 	read netmask
	   for (( counter=startip; counter<$lastip; counter++ ))
                        do
                           ipadd=10.64.$thirdoct.$counter
                           echo "Setting netmask on $ipadd"
                           $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 netmask $netmask)
                        done
                        echo "-----------------------------Complete-----------------------------------"
                       ;;
    7 ) echo "Please enter desired gateway:"
         read gateway
           for (( counter=startip; counter<$lastip; counter++ ))
                         do
                           ipadd=10.64.$thirdoct.$counter
                           echo "Setting gateway on $ipadd"
                           $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 gateway $gateway)
                         done
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
   8 ) echo "Please enter new username:"
        read chuser
           for (( counter=startip; counter<$lastip; counter++ ))
                          do
                          ipadd=10.64.$thirdoct.$counter
                          echo "Changing username for $ipadd"
                          $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass user set name 3 $chuser)
                          done
                          echo "-----------------------------Complete-----------------------------------"
                        ;;
   9 ) echo "Please enter new password:"
	read chpass
	   for (( counter=startip; counter<$lastip; counter++ ))
	                 do
	                 ipadd=10.64.$thirdoct.$counter
	                 echo "Changing password for $ipadd"
	                 $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P $pass user set password 3 $chpass)
	                 done
	                 echo "-----------------------------Complete-----------------------------------"
	               ;;
   10 ) for (( counter=startip; counter<$lastip; counter++ ))
                         do
                         ipadd=10.64.$thirdoct.$counter
                         echo "Clearing SEL for $ipadd"
                         $(/usr/bin/ipmitool -H $ipadd -U $user -P $pass sel clear)
                         done
                         echo "-----------------------------Complete-----------------------------------"
                      ;;

        $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
        *) echo "Invalid option. Try another one.";continue;;
esac

done
