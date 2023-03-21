#! /bin/bash

loadkeys us
echo "##############################################################################################"
echo "#                          ArmoredGoat's Artix Installation Script                           #"
echo "#                                 Last updated at 2023/03/20                                 #"
echo "#        Educationally inspired by https://github.com/rwinkhart/artix-install-script         #"
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

rootpassword="foo"
rootpasswordConf="bar"
while [[ $password != $passwordConf ]]; do
    read -rsp "Password: " rootpassword
    read -rsp "Confirm password: " rootpasswordConf
    if [ $password != $passwordConf ]; then
        echo "Passwords does not match. Please repeat."
    fi
done

read -rp "Hostname: " hostname

timezone="Europe/Berlin" # Temporarily hard coded

#read -r -s -p "Enter your password: "

##### HARDWARE DETECTION      #####

cpu=$(lscpu | grep 'Vendor ID:' | awk 'FNR == 1 {print $3;}')

threadsminusone=$(echo "$(lscpu | grep 'CPU(s):' | awk 'FNR == 1 {print $2;}') - 1" | bc)

gpu=$(lspci | grep 'VGA compatible controller:' | awk 'FNR == 1 {print $5;}')
if ! ([ "$gpu" == 'NVIDIA' ] || [ "$gpu" == 'Intel' ]); then
    gpu=AMD
fi

ram=$(echo "$(< /proc/meminfo)" | grep 'MemTotal:' | awk '{print $2;}'); ram=$(echo "$ram / 1000000" | bc)

# start conditional questions
if [ "$gpu" == 'Intel' ]; then
    echo -e '1. libva-intel-driver (intel igpus up to coffee lake)\n2. intel-media-driver (intel igpus/dgpus newer than coffee lake)\n'
    read -n 1 -rp "va-api driver: " intel_vaapi_driver
fi
# stop conditional questions

# start variable manipulation
# Change uppercase characters to lowercase
wipe=$(echo "$wipe" | tr '[:upper:]' '[:lower:]')
username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
hostname=$(echo "$hostname" | tr '[:upper:]' '[:lower:]')

# determine if running as UEFI or BIOS
# If /sys/firmware/efi exists it is an UEFI boot
if [ -d "/sys/firmware/efi" ]; then
    boot='uefi'
else
    boot='bios'
fi

# setting hostname
echo "$hostname" > /mnt/etc/hostname
echo "hostname=\'"$hostname"\'" > /mnt/etc/conf.d/hostname