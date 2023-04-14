#! /bin/bash

##########   START COLORS   

# Reset
colorOff='\033[0m'       # Text Reset

# Colors
blue='\033[0;34m'         # blue
purple='\033[0;35m'       # purple
cyan='\033[0;36m'         # cyan

##########   END COLORS

##########  START SPECIAL CHARACTERS

# Green = Accepted inputs/done steps
squareGreen="\033[0;32m\xE2\x96\x88\033[0m"
# Red = Denied inputs/canceled steps
squareRed="\033[0;31m\xE2\x96\x88\033[0m"
# YellowRead = Waiting for input
squareYellowRead=$'\033[0;33m\xE2\x96\x88\033[0m'
# Yellow = Steps not done yet
squareYellow="\033[0;33m\xE2\x96\x88\033[0m"

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

echo -e "${cyan}###############################################################\
#################"
echo -e "#                   ArmoredGoat's Artix Installation Script           \
         #"
echo -e "#                          Last updated at 2023/03/20                 \
         #"
echo -e "# Educationally inspired by https://github.com/rwinkhart/artix-install\
-script  #"
echo -e "######################################################################\
##########${colorOff}"

echo -e "\nBefore installation, a few questions have to be answered."
read -n 1 -sp $'\nPress any key to continue.'

delete_term_lines 3

##########   START MANUAL CONFIGURATION

echo -e "${purple}##############################   CONFIGURATION   ############\
###################${colorOff}"

echo -e "\n          ${blue}#################### INSTALLATION TYPE ############\
########${colorOff}"

echo -e "\n${green}1) Base installation${colorOff} 
    Only necessary packages and configuration.
    In the end you have a working but basic Artix installation.

${green}2) Customized installation${colorOff} 
    Take over all my configuration and user settings.
    It is not guaranteed that my configuration is one hundred percent compatible
    with your system, although this script is designed to be adaptive."

while true; do
    read -p $'\n'$squareYellowRead"    Which installation would you like to \
perfom (1-2)? " installationType
    case $installationType in
        1)
            delete_term_lines 11

            installationType='base'
            
            break
            ;;
        2)
            delete_term_lines 11
            
            installationType='custom'
            
            break
            ;;
        *)
            delete_term_lines 2

            echo -e "${squareRed}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
            ;;
    esac      
done

echo -e "${squareGreen}    Installation type '${installationType}' set!"

echo -e "\n          ${blue}####################    PARTITIONING   ############\
########${colorOff}"

echo -e "\n                    ${blue}##########   DISK SELECTION  ##########\
${colorOff}"

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
        read -p $'\n'$squareYellowRead"    Which disk shall be partitioned (1-\
$numberOfDisks)? " selectedDisk
    else
        read -p $'\n'$squareYellowRead"    Which disk shall be partitioned (1)?\
 " selectedDisk
    fi
    if (( 1 <= $selectedDisk && $selectedDisk <= $numberOfDisks )); then
            disk=$(sed "${selectedDisk}q;d" /tempfiles/availableDisks | \
            awk '{print $2}')
            
            delete_term_lines $(( $numberOfLines + 5 ))

            echo -e "${squareGreen}    Disk ${disk} selected."

            break
        else
            delete_term_lines 2

            echo -e "${squareRed}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
    fi    
done

# Ask for confirmation to wipe selected disk.
while true; do
    read -p $'\n'$squareYellowRead"   ${disk} will be completely wiped. Do you \
want to continue (y/N)? " wipe
    case $wipe in
        [yY][eE][sS]|[yY])
            delete_term_lines 2 0 1
            break
            ;;
        [nN][oO]|[nN]|"")
            delete_term_lines 2

            echo -e "${squareRed}    The installation will be aborted. Press \
any key to exit."
            read -sp $'\n'

            exit 0
            ;;
        *)
            delete_term_lines 2

            echo -e "${squareRed}    Invalid input..."
            sleep 2

            delete_term_lines 2 0 1
            ;;
    esac      
done

echo -e "\n                    ${blue}##########     SWAP SPACE    ##########\
${colorOff}"

# Ask how much swap space should be allocated and convert the value
# from Gibibyte to Megabyte.
echo -e "\n${squareYellow}    Setting size of swap space..."

read -rp $'\nSwap size in GiB: ' swap
delete_term_lines 4
echo -e "${squareGreen}    ${swap} GiB swap space set!"

echo -e "\n          ${blue}####################  SYSTEM SETTINGS  ############\
########${colorOff}"

echo -e "\n                    ${blue}##########   HOST SETTINGS   ##########\
${colorOff}"

# Ask for hostname and credentials. Ensuring that passwords match.
echo -e "\n${squareYellow}    Setting hostname..."

read -rp $'\nHostname: ' hostname
delete_term_lines 4
echo -e "${squareGreen}    Hostname '${hostname}' set!"

echo -e "\n                    ${blue}##########   USER SETTINGS   ##########\
${colorOff}"

echo -e "\n${squareYellow}    Setting username..."

read -rp $'\nUsername: ' username
delete_term_lines 4
echo -e "${squareGreen}    Username '${username}' set!"

echo -e "\n${squareYellow}    Setting user password..."
userPassword="foo"; userPasswordConf="bar"
while [ $userPassword != $userPasswordConf ]; do
    read -rsp $'\nUser password: ' userPassword
    delete_term_lines 0 1 1
    read -rsp $'Confirm user password: ' userPasswordConf
    if [[ $userPassword != $userPasswordConf && ${#userPassword} < 8 ]]; then
        delete_term_lines 0 1 1
        echo -e "${squareRed}    Passwords do not match AND are too short (at \
least 8 characters)."
        sleep 3
        delete_term_lines 2 1 1
    elif [[ $userPassword == $userPasswordConf && ${#userPassword} < 8 ]]; then
        delete_term_lines 0 1 1
        echo -e "${squareRed}    Passwords are too short (at least 8 \
characters)."
        userPassword="foo"; userPasswordConf="bar"
        sleep 3
        delete_term_lines 2 1 1
    elif [[ $userPassword != $userPasswordConf ]]; then
        delete_term_lines 0 1 1
        echo -e "${squareRed}    Passwords do not match."
        sleep 3
        delete_term_lines 2 1 1
    else
        # Erase all ouput done due to entering root password and confirm that
        # password is set
        delete_term_lines 3 1
        echo -e "${squareGreen}    User password set."
        break
    fi
done

while true; do
    read -p $'\n'$squareYellowRead"    Do you want to set a root password (y/N)\
? " setRootPassword
    case $setRootPassword in
        [yY][eE][sS]|[yY])
            delete_term_lines 1 0 1
            echo -e "${squareYellow}    Setting root password..."
            setRootPassword=true
            rootPassword="foo"; rootPasswordConf="bar"
            while [[ $rootPassword != $rootPasswordConf ]]; do
                read -rsp $'\nRoot password: ' rootPassword
                delete_term_lines 0 1 1
                read -rsp $'Confirm root password: ' rootPasswordConf
                if [[ $rootPassword != $rootPasswordConf && \
                ${#rootPassword} < 8 ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${squareRed}    Passwords do not match AND are \
too short (at least 8 characters)."
                    sleep 3
                    delete_term_lines 2 1 1
                elif [[ $rootPassword == $rootPasswordConf && \
                ${#rootPassword} < 8 ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${squareRed}    Passwords are too short (at least \
8 characters)."
                    rootPassword="foo"; rootPasswordConf="bar"
                    sleep 3
                    delete_term_lines 2 1 1
                elif [[ $rootPassword != $rootPasswordConf ]]; then
                    delete_term_lines 0 1 1
                    echo -e "${squareRed}    Passwords do not match."
                    sleep 3
                    delete_term_lines 2 1 1
                else
                    # Erase all ouput done due to entering root password and 
                    # confirm that password is set
                    delete_term_lines 3 1
                    echo -e "${squareGreen}    Root password set."
                    break
                fi
            done
            break
            ;;
        [nN][oO]|[nN]|"")
            setRootPassword=false
            delete_term_lines 2
            echo -e "${squareGreen}    No root password set."
            break
            ;;
        *)
            delete_term_lines 2
            echo -e "${squareRed}    Invalid input..."
            sleep 2
            ;;
    esac      
done

echo -e "\n                    ${blue}##########   TIME SETTINGS   ##########\
${colorOff}"

echo -e "\n${squareYellow}    Setting time zone..."
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
    read -p $'\n'$squareYellowRead"    Please enter your region's number (1-\
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

        echo -e "${squareRed}    Invalid input..."
        sleep 2

        delete_term_lines 2 0 1
    fi
done

echo -e "${squareYellow}    ${region} selected..."

echo ""

ls -l /usr/share/zoneinfo/$region | grep -v "\->" | \
tail -n +2 > /tempfiles/regionCities
numberOfCities="$(wc -l < /tempfiles/regionCities)"

ls -l /usr/share/zoneinfo/$region | grep -v "\->" | tail -n +2 | \
awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output
numberOfOutputLines=$(wc -l < /tempfiles/output)

while true; do
    if [[ $numberOfCities > "1" ]]; then
        read -p $'\n'$squareYellowRead"    Please enter your cities' number (1-\
$numberOfCities): " cityNumber
    else
        read -p $'\n'$squareYellowRead"    Please enter your cities' number \
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

        echo -e "${squareRed}    Invalid input..."
        sleep 2

        delete_term_lines 2 0 1
    fi 
done

if [[ -d /usr/share/zoneinfo/$region/$city ]]; then

    echo -e "${squareGreen}    ${region}/${city} selected..."

    echo ""

    ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | \
    tail -n +2 > /tempfiles/regionSubCities
    numberOfSubCities="$(wc -l < /tempfiles/regionSubCities)"

    ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | tail -n +2 | \
    awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output

    while true; do
        if [[ "$numberOfSubCities" > "1" ]]; then
            read -p $'\n'$squareYellowRead"    Please enter your cities' number\ 
 (1-$numberOfSubCities): " subCityNumber
        else
            read -p $'\n'$squareYellowRead"    Please enter your cities' number\
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

            echo -e "${squareRed}    Invalid input..."
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

echo -e "${squareGreen}    Time zone ${timezone} set."

echo -e "\n${purple}##############################    CONFIRMATION   ##########\
#####################${colorOff}"

# Ask for confirmation to continue with installation
while true; do
    read -p $'\n'$squareYellowRead"   Do you want to proceed the installation \
with the given information (y/N)? " proceed
    case $proceed in
        [yY][eE][sS]|[yY])
            delete_term_lines 2 0 1
            break
            ;;
        [nN][oO]|[nN]|"")
            delete_term_lines 2

            echo -e "${squareRed}    The installation will be aborted. Press \
any key to exit."
            read -sp $'\n'

            exit 0
            ;;
        *)
            delete_term_lines 2

            echo -e "${squareRed}    Invalid input..."
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
threadsMinusOne=$(( $(lscpu | grep 'CPU(s):' | \
awk 'FNR == 1 {print $2;}') - 1 ))
# Get GPU
gpu=$(lspci | grep 'VGA compatible controller:' | awk 'FNR == 1 {print $5;}')
if ! ([ "$gpu" == 'NVIDIA' ] || [ "$gpu" == 'Intel' ] || \
[ "$gpu" == 'VMware' ]); then
    gpu='AMD'
fi
# Get amount of RAM
ram=$(echo "$(< /proc/meminfo)" | grep 'MemTotal:' | awk '{print $2;}')
ram=$(( $ram / 1000000 ))

##########   END HARDWARE DETECTION

##########   START SOFTWARE DETECTION

# THAT'S NOT WORKING, SUBSTITUTE FOR INTERACTIVE MENU
# Detect init system by getting process with pid 1
#initSystem=$(ps -p 1 -o comm=)

##########   END SOFTWARE DETECTION

##########   START CONDITIONAL QUERIES

# Do not know why this is done, yet. Will implement it when I figured it out.
#if [ "$gpu" == 'Intel' ]; then
#    echo -e '1. libva-intel-driver (intel igpus up to coffee lake)\n2. \
#intel-media-driver (intel igpus/dgpus newer than coffee lake)\n'
#    read -n 1 -rp "va-api driver: " intel_vaapi_driver
#fi

# In case of NVME or SD/MMC device, append 'p' to adress Linux' 
#way of naming partitions.
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

swapDevice=$(cat /proc/swaps | grep "partition" | awk '{print $1}')
if [[ $swapDevice ]]; then
    swapoff $swapDevice
fi

# In case of UEFI boot --> GPT/UEFI partitioning with 1 GiB disk space 
# for boot partition
# In case of BIOS boot --> MBR/BIOS partitioning
if [ "$boot" == 'uefi' ]; then
    wipefs --all --force $baseDisk
    echo 'g # Create new GPT disklabel
    n # New partition
    1 # Partition number 1
      # Default - start at beginning of disk 
    +1024M  # 1 GiB boot partition
    t # Set type of partiton
    1 # Set type to 'EFI System'
    n # New partition
    2 # Partition number 2
      # Default - start at beginning of remaining disk 
    +'$swap' # Partiton size equal to given swap value
    t # Set type of partiton
    2 # Select partition 2
    19 # Set type to 'Linux Swap'
    n # New partition
    3 # Partition number 3
      # Default - start at beginning of remaining disk
      # Default - use remaining disk space
    w # Write the partition table
    ' | sfdisk -w always -W always $baseDisk

    # Format and label disks
    mkfs.fat -F 32 $disk'1'
    fatlabel $disk'1' ESP
    
    mkswap -L SWAP $disk'2'
    
    mkfs.ext4 -L ROOT $disk'3'
        
    # Mount storage and EFI partitions, and create necessary directories
    swapon /dev/disk/by-label/SWAP
    mount /dev/disk/by-label/ROOT /mnt
    
    mkdir -p /mnt/{boot,boot/efi,etc/conf.d,home}
    mount /dev/disk/by-label/ESP /mnt/boot/efi
else
    partitions=0
    echo 'o # Clear in memory partition table
    n # New partition
    p # Primary partition
    1 # Partition number 1
      # Default - start at beginning of disk 
    +'$swap' # Partiton size equal to given swap value
    n # New partition
    p # Primary partition
      # Default - start at beginning of disk 
    -1M # Use remaining disk space minus 1 M
    w # Write the partition table
    ' | fdisk -w always -W always $baseDisk

    # Format and label disks
    mkswap -L SWAP $disk'1'
    
    mkfs.ext4 -L ROOT $disk'2'

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
    # base-devel    - Package group with tools for building 
    #                 (compiling and linking) software
    #base_devel="db diffutils gc guile libisl libmpc perl autoconf \
    # automake bash binutils bison esysusers /tempfilesfiles fakeroot \
    # file findutils flex gawk gcc gettext grep groff gzip libtool m4 \
    # make pacman pacman-contrib patch pkgconf python sed opendoas texinfo \
    # which bc udev"
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

basestrap /mnt $basePackages $initSystem $loginManager $kernel $firmware \
$network

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

curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/main/\
chrootInstall.sh -o /mnt/chrootInstall.sh
chmod +x /mnt/chrootInstall.sh
artix-chroot /mnt /chrootInstall.sh
