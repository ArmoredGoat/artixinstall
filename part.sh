#! /bin/bash

##########   START COLORS   

# Reset
colorOff='\033[0m'       # Text Reset

# Colors
blue='\033[0;34m'         # blue
purple='\033[0;35m'       # purple
cyan='\033[0;36m'         # cyan
red='\033[0;31m'          # red
green='\033[0;32m'        # green

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
    wipefs --all --force "$baseDisk"
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk -w always -W always "$baseDisk"
        g # Create new GPT disklabel
        n # New partition
        1 # Partition number 1
          # Default - Start at beginning of disk
        +1024M # 1 GiB boot parttion
        t # Set type of partiton
        1 # Set type to 'EFI System'
        n # New partition
        2 # Partition number 2
          # Default - Start at beginning of remaining disk
        +$swap # Partiton size equal to given swap value
        t # Set type of partiton
        2 # Select partition 2
        19 # Set type to 'Linux Swap'
        n # New partition
        3 # Partition number 3
          # Default - start at beginning of remaining disk
          # Default - use remaining disk space
        w # Write the partition table
        q # Quit fdisk
EOF

    # Format and label disks
    mkfs.fat -F 32 "$disk"'1'
    fatlabel "$disk"'1' ESP
    
    mkswap -L SWAP "$disk"'2'
    
    mkfs.ext4 -L ROOT "$disk"'3'
        
    # Mount storage and EFI partitions, and create necessary directories
    swapon "$disk"'2'
    mount "$disk"'3' /mnt
    
    mkdir -p /mnt/{boot,boot/efi,etc/conf.d,home}
    mount  "$disk"'1' /mnt/boot/efi
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
    swapon "$disk"'1'
    mount "$disk"'2' /mnt
    
    mkdir -p /mnt/etc/conf.d
fi

##########   END PARTITIONING

lsblk