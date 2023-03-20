#! /bin/bash

loadkeys us
echo "##############################################################################################"
echo "#                          ArmoredGoat's Artix Installation Script                           #"
echo "#                                 Last updated at 2023/03/20                                 #"
echo "##############################################################################################"

echo "Before installation, a few question have to be answered."
read -n 1 -srp "Press any key to continue."

printf "\nAvailable disks\n"
lsblk --tree | grep 'NAME\|disk\|part'

read -rp "Which disk shall be partitioned? " disk

read -rp "Swap size in GB: " swap

while true
do
      read -n 1 -rp "Do you want to perform a clean install? (y/N)" wipe
      case $wipe in
            [yY][eE][sS]|[yY])
                  echo "Yes"
                  break
                  ;;
            [nN][oO]|[nN])
                  echo "No"
                  break
                  ;;
            *)
                  echo "Invalid input..."
                  ;;
      esac      
done

read -rp "Username: " username

password="foo"
passwordConf="bar"
while [[ $password != $passwordConf ]]; do
    read -rsp "Password: " password
    read -rsp "Confirm password: " passwordConf
    if [ $password != $passwordConf ]; then
        echo "Passwords does not match. Please repeat."
    fi
done

read -rp "Hostname: " hostname

#read -r -s -p "Enter your password: "


# setting hostname
echo "$hostname" > /mnt/etc/hostname
echo "hostname=\'"$hostname"\'" > /mnt/etc/conf.d/hostname