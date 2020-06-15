#!/bin/bash
clear
echo -e "\e[33mStudioCloud\e[0m IPMItool Automation"
prompt="Pick an option:"
options=("Power on/off" "UID on/off" "Power Cycle" "Set VLAN" "Change subnet" "Set Netmask" "Set Gateway" "Change Username" "Change Password" "Clear SEL")

echo "Welcome to StudioCloud's IPMItool Automator"
echo "Please enter the first 3 octets of the network, ex. 10.64.80?"
read octets
echo "Okay so, $octets.x - What's the first node's IP in that subnet? (Ex. 1)"
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
                            ipadd=$octets.$counter
                            echo "Powering $power $ipadd"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' power $power &) &
			    sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    2 ) echo "UID time on amount? [Enter number, ex '1' for 1 second, or enter 'force' to stay on]"
        echo "Note: Entering '1' for one second is how you get it to turn off"
            read timer
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Setting UID for $ipadd"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' chassis identify $timer &) &
			    sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    3 )     for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Restarting $ipadd"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' chassis power cycle &) &
			    sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    4 ) echo "Enter desired VLAN: (Enter 'off' to disable)"
        read vlan
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Setting $ipadd to VLAN $vlan"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' lan set 0x01 vlan id $vlan &) &
			    sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
    5 ) echo "Enter new subnet for IPs: (Ex. enter '115' to change 10.64.?.x to 10.64.115.x)"
                        read newsub
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Changing $ipadd to 10.64.$newsub.$counter"
                            $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' lan set 1 ipaddr 10.64.$newsub.$counter &) &
			    sleep .5
                         done;
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
   6 ) echo "Please enter desired netmask:"
        read netmask
           for (( counter=startip; counter<$lastip; counter++ ))
                        do
                           ipadd=$octets.$counter
                           echo "Setting netmask on $ipadd"
                           $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' lan set 1 netmask $netmask &) &
			   sleep .5
                        done
                        echo "-----------------------------Complete-----------------------------------"
                       ;;
    7 ) echo "Please enter desired gateway:"
         read gateway
           for (( counter=startip; counter<$lastip; counter++ ))
                         do
                           ipadd=$octets.$counter
                           echo "Setting gateway on $ipadd"
                           $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' lan set 1 defgw ipaddr $gateway &) &
			   sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
   8 ) echo "Current users:"
   $(/usr/bin/ipmitool -I lanplus -H $octets.$startip -U $user -P '$pass' user list)
		echo "Select an ID slot:"
		read slot
		echo "Please enter new username:"
        read chuser
           for (( counter=startip; counter<$lastip; counter++ ))
                          do
                          ipadd=$octets.$counter
                          echo "Changing username for $ipadd"
                          $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' user set name $slot $chuser &) &
			  sleep .5
                          done
                          echo "-----------------------------Complete-----------------------------------"
                        ;;
   9 ) echo "Please enter new password:"
        read chpass
           for (( counter=startip; counter<$lastip; counter++ ))
                         do
                         ipadd=$octets.$counter
                         echo "Changing password for $ipadd"
                         $(/usr/bin/ipmitool -I lanplus -H $ipadd -U $user -P '$pass' user set password 3 $chpass &) &
			 sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                       ;;
   10 ) for (( counter=startip; counter<$lastip; counter++ ))
                         do
                         ipadd=$octets.$counter
                         echo "Clearing SEL for $ipadd"
                         $(/usr/bin/ipmitool -H $ipadd -U $user -P '$pass' sel clear &) &
			 sleep .5
                         done
                         echo "-----------------------------Complete-----------------------------------"
                      ;;

        $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
        *) echo "Invalid option. Try another one.";continue;;
esac

done
