#!/bin/bash
export PATH=$PATH:/usr/bin/
clear
echo -e "\e[33mStudioCloud\e[0m RACADM Automation"
prompt="Pick an option:"
options=("Initial Setup" "Power Capping" "Power Cycle" "Power On" "Change subnet" "Set Netmask" "Set Gateway" "Change Username" "Change Password" "Change active IP Subnet" "Change active IP Range")

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

    1 ) echo "Initial setup"
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Setting Initial Config for $ipadd"
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass set iDRAC.Tuning.DefaultCredentialWarning Disabled & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass set iDRAC.IPMILan.Enable 1 & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass set iDRAC.nic.failover all & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass set NIC.NICConfig.1.LegacyBootProto PXE & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass jobqueue create NIC.Integrated.1-1-1 & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass set BIOS.BiosBootSettings.BootMode Bios & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass jobqueue create BIOS.Setup.1-1 -r pwrcycle -s TIME_NOW -e TIME_NA & >> output
                                                        racadm --nocertwarn -r $ipadd -u $user -p $pass serveraction powercycle & >> output
                            sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    2 ) echo "Set Power Cap"
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Setting Power Cap (614W) $ipadd"
                                racadm --nocertwarn -r $ipadd -u $user -p $pass set System.ServerPwr.PowerCapSetting 1 & >> output
                                racadm --nocertwarn -r $ipadd -u $user -p $pass set System.ServerPwr.PowerCapValue 614 & >> output
                            sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    3 )     for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Restarting $ipadd"
                            ipmitool -I lanplus -H $ipadd -U $user -P $pass chassis power cycle &
                            sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
                   ;;
    4 )      for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Restarting $ipadd"
                            ipmitool -I lanplus -H $ipadd -U $user -P $pass chassis power on &
                            sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
    5 ) echo "Enter new subnet for IPs: (Ex. enter '115' to change 10.64.?.x to 10.64.115.x)"
                        read newsub
            for (( counter=startip; counter<$lastip; counter++ ))
                         do
                            ipadd=$octets.$counter
                            echo "Changing $ipadd to 10.64.$newsub.$counter"
                            ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 ipaddr 10.64.$newsub.$counter &
                            sleep .1
                         done;
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
   6 ) echo "Please enter desired netmask:"
        read netmask
           for (( counter=startip; counter<$lastip; counter++ ))
                        do
                           ipadd=$octets.$counter
                           echo "Setting netmask on $ipadd"
                           ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 netmask $netmask &
                           sleep .1
                        done
                        echo "-----------------------------Complete-----------------------------------"
                       ;;
    7 ) echo "Please enter desired gateway:"
         read gateway
           for (( counter=startip; counter<$lastip; counter++ ))
                         do
                           ipadd=$octets.$counter
                           echo "Setting gateway on $ipadd"
                           ipmitool -I lanplus -H $ipadd -U $user -P $pass lan set 1 defgw ipaddr $gateway &
                           sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
                        ;;
   8 ) echo "Current users:"
   $(/usr/bin/ipmitool -I lanplus -H $octets.$startip -U $user -P $pass user list >> output)
                echo "Select an ID slot:"
                read slot
                echo "Please enter new username:"
        read chuser
           for (( counter=startip; counter<$lastip; counter++ ))
                          do
                          ipadd=$octets.$counter
                          echo "Changing username for $ipadd"
                          ipmitool -I lanplus -H $ipadd -U $user -P $pass user set name $slot $chuser &
                          sleep .1
                          done
                          echo "-----------------------------Complete-----------------------------------"
                        ;;
   9 ) echo "Select an ID slot:"
                read slot
                echo "Please enter new password:"
        read chpass
           for (( counter=startip; counter<$lastip; counter++ ))
                         do
                         ipadd=$octets.$counter
                         echo "Changing password for $ipadd"
                         ipmitool -I lanplus -H $ipadd -U $user -P $pass user set password $slot $chpass &
                         sleep .1
                         done
                         echo "-----------------------------Complete-----------------------------------"
                       ;;
   10 ) echo "Please enter the first 3 octets of the network, ex. 10.64.80?"
                        read octets
                      ;;
   11 ) echo "Change IP Range"
                echo "Okay so, $octets.x - What's the first node's IP in that subnet? (Ex. 1)"
                read startip
                echo "What is the last node IP? (Ex. 96)"
                read lastip
                (( lastip=$lastip+1 ))
                      ;;

        $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
        *) echo "Invalid option. Try another one.";continue;;
esac

done
