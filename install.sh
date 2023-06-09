#! /bin/bash

##########   START COLORS   

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

##########   END COLORS

##########  START SPECIAL CHARACTERS

CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
CROSS_MARK="\033[0;31m\xE2\x9C\x96\033[0m"
QUEST_MARK=$'\033[0;33m\xE2\x9D\x94\033[0m'
EXCLA_MARK="\033[0;33m\xE2\x9D\x95\033[0m"

##########  END SPECIAL CHARACTERS

##########  START FUNCTIONS

# \r jumps to beginning of line
# \033 marks beginning of escape sequence
# [1A moves one line up
# [0K erase from cursor to right end

delete_term_lines () {
    local ERASE_CURR="\r\033[0K"
    local ERASE_PREV="\r\033[1A\033[0K"
    local MOVE_CURSOR_UP="\033[1A"
    local ERASE_STRING=""
    if [[ $2 ]]; then
        ERASE_STRING+="${ERASE_CURR}"
    fi
    for (( i=0; i < $1; i++ )); do
        ERASE_STRING+="${ERASE_PREV}"
    done
    if [[ $3 ]]; then
        ERASE_STRING+="${MOVE_CURSOR_UP}"
    fi
    echo -e "${ERASE_STRING}"
}

##########  END FUNCTIONS

# Create directory for storing temp files/variables
if [[ ! -d /tempfiles ]]; then
    mkdir /tempfiles
fi

# Load keymap us
loadkeys us

echo -e "${Cyan}###############################################################\
#################"
echo -e "#                   ArmoredGoat's Artix Installation Script           \
         #"
echo -e "#                          Last updated at 2023/03/20                 \
         #"
echo -e "# Educationally inspired by https://github.com/rwinkhart/artix-install\
-script  #"
echo -e "######################################################################\
##########${Color_Off}"

echo -e "\nBefore installation, a few questions have to be answered."
read -n 1 -sp $'\nPress any key to continue.'

delete_term_lines 3

##########   START MANUAL CONFIGURATION

echo -e "${Purple}##############################   CONFIGURATION   ############\
###################${Color_Off}"

echo -e "\n          ${Blue}#################### INSTALLATION TYPE ############\
########${Color_Off}"

echo -e "\n${Green}1) Base installation${Color_Off} 
    Only necessary packages and configuration.
    In the end you have a working but basic Artix installation.

${Green}2) Customized installation${Color_Off} 
    Take over all my configuration and user settings.
    It is not guaranteed that my configuration is one hundred percent compatible
    with your system, although this script is designed to be adaptive."

while true; do
    read -p $'\n'$QUEST_MARK"    Which installation would you like to perfom (1-\
2)? " installationType
    case $installationType in
        1)
            delete_term_lines 11

            installationType='base'
            echo -e "${CHECK_MARK}    Installation type '${installationType}' \
set!" 
            break
            ;;
        2)
#            delete_term_lines 11
#            
#            installationType='custom'
#            echo -e "${CHECK_MARK}    Installation type '${installationType}' \
#set!" 
#            break
            delete_term_lines 2

            echo -e "${CROSS_MARK}    Not available yet. Please choose Base \
Installation"
            sleep 2

            delete_term_lines 2 0 1
            ;;
        *)
            delete_term_lines 2

            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
            ;;
    esac      
done

echo -e "\n          ${Blue}####################    PARTITIONING   ############\
########${Color_Off}"

echo -e "\n                    ${Blue}##########   DISK SELECTION  ##########\
${Color_Off}"

# List available disks
echo -e "\n$(lsblk --tree | grep 'NAME\|disk\|part')" | tee /tempfiles/output
numberOfLines=$(wc -l < /tempfiles/output)
# Store available disks in temp file, enumerates them, and display choices
(lsblk --list -d | grep disk | awk '{print NR") /dev/" $1}') > \
/tempfiles/availableDisks

echo ""
while IFS= read -r line; do
    echo $line
done < /tempfiles/availableDisks

# Get number of lines of temp file = number of choices
numberOfDisks=$(wc -l < /tempfiles/availableDisks)
# Disk can be selected by entering its number 
while true; do
    if [[ "$numberOfDisks" > "1" ]]; then
        read -p $'\n'$QUEST_MARK"    Which disk shall be partitioned (1-\
$numberOfDisks)? " selectedDisk
    else
        read -p $'\n'$QUEST_MARK"    Which disk shall be partitioned (1)? " \
        selectedDisk
    fi
    if (( 1 <= $selectedDisk && $selectedDisk <= $numberOfDisks )); then
            disk=$(sed "${selectedDisk}q;d" /tempfiles/availableDisks | \
            awk '{print $2}')
            
            delete_term_lines $(( $numberOfLines + 5 ))

            echo -e "${CHECK_MARK}    Disk ${disk} selected."

            break
        else
            delete_term_lines 2

            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
    fi    
done

# Ask for confirmation to wipe selected disk.
while true; do
    read -p $'\n'$QUEST_MARK"   ${disk} will be completely wiped. Do you want \
to continue (y/N)? " wipe
    case $wipe in
        [yY][eE][sS]|[yY])
            delete_term_lines 2 0 1
            break
            ;;
        [nN][oO]|[nN]|"")
            delete_term_lines 2

            echo -e "${CROSS_MARK}    The installation will be aborted. Press \
any key to exit."
            read -sp $'\n'

            exit 0
            ;;
        *)
            delete_term_lines 2

            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
            ;;
    esac      
done

echo -e "\n                    ${Blue}##########     SWAP SPACE    ##########\
${Color_Off}"

# Ask how much swap space should be allocated and convert the value
# from Gibibyte to Megabyte.
echo -e "\n${EXCLA_MARK}    Setting size of swap space..."

read -rp $'\nSwap size in GiB: ' swap
delete_term_lines 4
echo -e "${CHECK_MARK}    ${swap} GiB swap space set!"

echo -e "\n          ${Blue}####################  SYSTEM SETTINGS  #############\
#######${Color_Off}"

echo -e "\n                    ${Blue}##########   HOST SETTINGS   ##########\
${Color_Off}"

# Ask for hostname and credentials. Ensuring that passwords match.
echo -e "\n${EXCLA_MARK}    Setting hostname..."

read -rp $'\nHostname: ' hostname
delete_term_lines 4
echo -e "${CHECK_MARK}    Hostname '${hostname}' set!"

echo -e "\n                    ${Blue}##########   USER SETTINGS   ##########\
${Color_Off}"

echo -e "\n${EXCLA_MARK}    Setting username..."

read -rp $'\nUsername: ' username
delete_term_lines 4
echo -e "${CHECK_MARK}    Username '${username}' set!"

echo -e "\n${EXCLA_MARK}    Setting user password..."
userPassword="foo"; userPasswordConf="bar"
while [ $userPassword != $userPasswordConf ]; do
    read -rsp $'\nUser password: ' userPassword
    delete_term_lines 0 1 1
    read -rsp $'Confirm user password: ' userPasswordConf
    if [[ $userPassword != $userPasswordConf && ${#userPassword} < 8 ]]; then
        delete_term_lines 0 1 1
        echo -e "${CROSS_MARK}    Passwords do not match AND are too short (at \
least 8 characters)."
        sleep 3
        delete_term_lines 2 1 1
    elif [[ $userPassword == $userPasswordConf && ${#userPassword} < 8 ]]; then
        delete_term_lines 0 1 1
        echo -e "${CROSS_MARK}    Passwords are too short (at least 8 \
characters)."
        userPassword="foo"; userPasswordConf="bar"
        sleep 3
        delete_term_lines 2 1 1
    elif [[ $userPassword != $userPasswordConf ]]; then
        delete_term_lines 0 1 1
        echo -e "${CROSS_MARK}    Passwords do not match."
        sleep 3
        delete_term_lines 2 1 1
    else
        # Erase all ouput done due to entering root password and confirm that
        # password is set
        delete_term_lines 3 1
        echo -e "${CHECK_MARK}    User password set."
        break
    fi
done

while true; do
    read -p $'\n'$QUEST_MARK"    Do you want to set a root password (y/N)? " setRootPassword
    case $setRootPassword in
        [yY][eE][sS]|[yY])
            delete_term_lines 1 0 1
            echo -e "${EXCLA_MARK}    Setting root password..."
            setRootPassword=true
            rootPassword="foo"; rootPasswordConf="bar"
            while [[ $rootPassword != $rootPasswordConf ]]; do
                read -rsp $'\nRoot password: ' rootPassword
                delete_term_lines 0 1 1
                read -rsp $'Confirm root password: ' rootPasswordConf
                if [[ $rootPassword != $rootPasswordConf && ${#rootPassword} < 8 ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${CROSS_MARK}    Passwords do not match AND are \
too short (at least 8 characters)."
                    sleep 3
                    delete_term_lines 2 1 1
                elif [[ $rootPassword == $rootPasswordConf && ${#rootPassword} < 8 ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${CROSS_MARK}    Passwords are too short (at least 8 characters)."
                    rootPassword="foo"; rootPasswordConf="bar"
                    sleep 3
                    delete_term_lines 2 1 1
                elif [[ $rootPassword != $rootPasswordConf ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${CROSS_MARK}    Passwords do not match."
                    sleep 3
                    delete_term_lines 2 1 1
                else
                    # Erase all ouput done due to entering root password and 
                    # confirm that password is set
                    delete_term_lines 3 1
                    echo -e "${CHECK_MARK}    Root password set."
                    break
                fi
            done
            break
            ;;
        [nN][oO]|[nN]|"")
            setRootPassword=false
            delete_term_lines 2
            echo -e "${CHECK_MARK}    No root password set."
            break
            ;;
        *)
            delete_term_lines 2
            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2
            ;;
    esac      
done

echo -e "\n                    ${Blue}##########   TIME SETTINGS   ##########\
${Color_Off}"

echo -e "\n${EXCLA_MARK}    Setting time zone..."
echo ""
echo "1) Africa
2) America
3) Asia
4) Atlantic
5) Australia
6) Europe
7) Pacific
8) Etc" | tee /tempfiles/regions
numberOfRegions="$(wc -l < /tempfiles/regions)"

while true; do
    read -p $'\n'$QUEST_MARK"    Please enter your region's number (1 - \
$numberOfRegions): " regionNumber
    if (( 1 <= $regionNumber && $regionNumber <= $numberOfRegions )); then
        region=$((sed "${regionNumber}q;d" /tempfiles/regions) | \
        awk '{print $2}')

        delete_term_lines 11 1

        break
    else
        if [[ $regionNumber == "" ]]; then
            delete_term_lines 3
        else
            delete_term_lines 2
        fi

        echo -e "${CROSS_MARK}    Invalid input..."
        sleep 2

        delete_term_lines 2 0 1
    fi
done

echo -e "${CHECK_MARK}    ${region} selected..."

echo ""

ls -l /usr/share/zoneinfo/$region | grep -v "\->" | \
tail -n +2 > /tempfiles/regionCities
numberOfCities="$(wc -l < /tempfiles/regionCities)"

ls -l /usr/share/zoneinfo/$region | grep -v "\->" | tail -n +2 | \
awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output
numberOfOutputLines=$(wc -l < /tempfiles/output)

while true; do
    if [[ $numberOfCities > "1" ]]; then
        read -p $'\n'$QUEST_MARK"    Please enter your cities' number (1 - \
$numberOfCities): " cityNumber
    else
        read -p $'\n'$QUEST_MARK"    Please enter your cities' number \
        (1): " cityNumber
    fi
    if (( 1 <= $cityNumber && $cityNumber <= $numberOfCities )); then
        city=$(sed "${cityNumber}q;d" /tempfiles/regionCities | \
        awk '{print $9}')

        delete_term_lines $(( $numberOfOutputLines + 5 ))

        break
    else
        if [[ $cityNumber == "" ]]; then
            delete_term_lines 3
        else
            delete_term_lines 2
        fi

        echo -e "${CROSS_MARK}    Invalid input..."
        sleep 2

        delete_term_lines 2 0 1
    fi 
done

if [[ -d /usr/share/zoneinfo/$region/$city ]]; then

    echo -e "${CHECK_MARK}    ${region}/${city} selected..."

    echo ""

    ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | \
    tail -n +2 > /tempfiles/regionSubCities
    numberOfSubCities="$(wc -l < /tempfiles/regionSubCities)"

    ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | tail -n +2 | \
    awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output

    while true; do
        if [[ "$numberOfSubCities" > "1" ]]; then
            read -p $'\n'$QUEST_MARK"    Please enter your cities' number (1 - \
$numberOfSubCities): " subCityNumber
        else
            read -p $'\n'$QUEST_MARK"    Please enter your cities' number \
(1): " subCityNumber
        fi
        if (( 1 <= $subCityNumber && $subCityNumber <= $numberOfCities )); then
            subCity=$(sed "${subCityNumber}q;d" /tempfiles/regionSubCities | \
            awk '{print $9}')
            
            delete_term_lines 8
            
            break
        else
            if [[ $subCityNumber == "" ]]; then
                delete_term_lines 3
            else
                delete_term_lines 2
            fi

            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
        fi 
    done

else
    delete_term_lines 3

fi

if [ $subCity ]; then
    timezone="$region/$city/$subCity"
else
    timezone="$region/$city"
fi

echo -e "${CHECK_MARK}    Time zone ${timezone} set."

echo -e "\n${Purple}##############################    CONFIRMATION   ##########\
#####################${Color_Off}"

# Ask for confirmation to continue with installation
while true; do
    read -p $'\n'$QUEST_MARK"   Do you want to proceed the installation with \
the given information (y/N)? " proceed
    case $proceed in
        [yY][eE][sS]|[yY])
            delete_term_lines 2 0 1
            break
            ;;
        [nN][oO]|[nN]|"")
            delete_term_lines 2

            echo -e "${CROSS_MARK}    The installation will be aborted. Press \
any key to exit."
            read -sp $'\n'

            exit 0
            ;;
        *)
            delete_term_lines 2

            echo -e "${CROSS_MARK}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
            ;;
    esac      
done

##########   END MANUAL CONFIGURATION

##########   START HARDWARE DETECTION

# Get CPU and threads 
# TODO Insert reason for detection
cpu=$(lscpu | grep 'Vendor ID:' | awk 'FNR == 1 {print $3;}')
threadsMinusOne=$(( $(lscpu | grep 'CPU(s):' | awk 'FNR == 1 {print $2;}') - 1 ))
# Get GPU
gpu=$(lspci | grep 'VGA compatible controller:' | awk 'FNR == 1 {print $5;}')
if ! ([ "$gpu" == 'NVIDIA' ] || [ "$gpu" == 'Intel' ] || [ "$gpu" == 'VMware' ]); then
    gpu='AMD'
fi
# Get amount of RAM
ram=$(echo "$(< /proc/meminfo)" | grep 'MemTotal:' | awk '{print $2;}'); ram=$(( $ram / 1000000 ))

##########   END HARDWARE DETECTION

##########   START SOFTWARE DETECTION

# THAT'S NOT WORKING, SUBSTITUTE FOR INTERACTIVE MENU
# Detect init system by getting process with pid 1
#initSystem=$(ps -p 1 -o comm=)

##########   END SOFTWARE DETECTION

##########   START CONDITIONAL QUERIES

# Do not know why this is done, yet. Will implement it when I figured it out.
#if [ "$gpu" == 'Intel' ]; then
#    echo -e '1. libva-intel-driver (intel igpus up to coffee lake)\n2. intel-media-driver (intel igpus/dgpus newer than coffee lake)\n'
#    read -n 1 -rp "va-api driver: " intel_vaapi_driver
#fi

# In case of NVME or SD/MMC device, append 'p' to adress Linux' way of naming partitions.
baseDisk=$disk
if [[ "$disk" == /dev/nvme0n* ]] || [[ "$disk" == /dev/mmcblk* ]]; then
    disk="$disk"'p'
fi

# Determine if UEFI or BIOS boot. If /sys/firmware/efi exists --> UEFI boot
if [ -d "/sys/firmware/efi" ]; then
    boot='uefi'
else
    boot='bios'
fi

##########   END CONDITIONAL QUERIES

##########   START VARIABLE MANIPULATION

# Change uppercase characters to lowercase for username and hostname
username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
hostname=$(echo "$hostname" | tr '[:upper:]' '[:lower:]')
# Convert size of swap space from gibibyte to megabyte
swap="$(( $swap * 1024 ))"'M'

##########   END VARIABLE MANIPULATION

##########   START PARTITIONING

# In case of UEFI boot --> GPT/UEFI partitioning with 1 GiB disk space for boot partition
# In case of BIOS boot --> MBR/BIOS partitioning
if [ "$boot" == 'uefi' ]; then
    wipefs --all --force "$baseDisk"
    echo 'g
    n
    1

    +1024M
    t
    1
    n
    2

    +'$swap'
    t
    2
    19
    n
    3

    
    w
    ' | fdisk -w always -W always "$baseDisk"

    # Format and label disks
    mkfs.fat -F 32 "$disk"'1'; fatlabel "$disk"'1' ESP
    mkswap -L SWAP "$disk"'2'
    mkfs.ext4 -L ROOT "$disk"'3'
        
    # Mount storage and EFI partitions, and create necessary directories
    swapon /dev/disk/by-label/SWAP
    mount /dev/disk/by-label/ROOT /mnt
    mkdir -p /mnt/{boot,boot/efi,etc/conf.d,home}
    mount /dev/disk/by-label/ESP /mnt/boot/efi
else
    partitions=0
    echo 'o
    n
    p
    1

    +'$swap'
    n
    p

    -1M
    w
    ' | fdisk -w always -W always "$baseDisk"

    # Format and label disks
    mkswap -L SWAP "$disk"'1'
    mkfs.ext4 -L ROOT "$disk"'2'

    # Mount storage and EFI partitions, and create necessary directories
    swapon /dev/disk/by-label/SWAP
    mount /dev/disk/by-label/ROOT /mnt
    mkdir -p /mnt/etc/conf.d
fi

##########   END PARTITIONING

##########   START BASE INSTALLATION

# Generate filesystem table
fstabgen -U /mnt >> /mnt/etc/fstab

# Set hostname
echo $hostname > /mnt/etc/hostname
echo "hostname='$hostname'" > /mnt/etc/conf.d/hostname

# Activate NTP daemon to synchronize computer's real-time clock
rc-service ntpd start
#  sv up ntpd   s6-rc -u change ntpd   dinitctl start ntpd

# Install packages
# TODO Add explanation to choice of packages
# Base packages
    # base          - 
    # base-devel    - Package group with tools for building (compiling and linking) software
    #base_devel='db diffutils gc guile libisl libmpc perl autoconf automake bash binutils bison esysusers /tempfilesfiles fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman pacman-contrib patch pkgconf python sed opendoas texinfo which bc udev'
basePackages="base base-devel"

initSystem="openrc"

# Login manager
    # elogind   - 
loginManager="elogind-"$initSystem

# Linux kernel
    # linux-lts, zen, ...
kernel="linux-lts"

# Firmware
    # linux-firmware    -
    # sof-firmware      -
firmware="linux-firmware"

# Network
    # networkmanager                -
    # networkmanager-$initSystem    -
    # dhcpcd                        -
network="networkmanager-$initSystem dhcpcd"

basestrap /mnt $basePackages $initSystem $loginManager $kernel $firmware $network

##########   END BASE INSTALLATION

##########   START EXPORTING VARIABLES

mkdir /mnt/tempfiles
#echo "$formfactor" > /mnt/tempfiles/formfactor
echo "$cpu" > /mnt/tempfiles/cpu
echo "$threadsMinusOne" > /mnt/tempfiles/threadsMinusOne
echo "$gpu" > /mnt/tempfiles/gpu
#echo "$intel_vaapi_driver" > /mnt/tempfiles/intel_vaapi_driver
echo "$boot" > /mnt/tempfiles/boot
echo "$baseDisk" > /mnt/tempfiles/disk
echo "$username" > /mnt/tempfiles/username
echo "$userPassword" > /mnt/tempfiles/userPassword
echo "$setRootPassword" > /mnt/tempfiles/setRootPassword
echo "$rootPassword" > /mnt/tempfiles/rootPassword
echo "$timezone" > /mnt/tempfiles/timezone

##########   END EXPORTING VARIABLES

curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/main/chrootInstall.sh -o /mnt/chrootInstall.sh
chmod +x /mnt/chrootInstall.sh
artix-chroot /mnt /chrootInstall.sh
