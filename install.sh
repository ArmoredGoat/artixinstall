#! /bin/bash

gitUrl="https://github.com/ArmoredGoat/artixinstall.git"
baseUrlRaw="https://raw.githubusercontent.com"
gitRepo="ArmoredGoat/artixinstall"
gitBranch="iss008"
downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"

main () {
    # Declare variables for colors and special characters to style ouput.
    declare_colors
    declare_special_characters
    # Create directory for storing variables and temporary files
    create_directory /tempfiles
    # Load US keymap
    load_keymap us
    # Print welcome message
    print_head_message

    set_manual_configuration

    get_boot_type
}

declare_colors () {
    # Set variable to set color back to normal
    colorOff='\033[0m'       # Text Reset
    # Set variables to color terminal output
    blue='\033[0;34m'         # blue
    purple='\033[0;35m'       # purple
    cyan='\033[0;36m'         # cyan
    red='\033[0;31m'          # red
    green='\033[0;32m'        # green
}

declare_special_characters () {
    # Set variables to special characters to indicate status of step
    # Green = Accepted inputs/done steps
    squareGreen="\033[0;32m\xE2\x96\x88\033[0m"
    # Red = Denied inputs/canceled steps
    squareRed="\033[0;31m\xE2\x96\x88\033[0m"
    # YellowRead = Waiting for input
    squareYellowRead=$'\033[0;33m\xE2\x96\x88\033[0m'
    # Yellow = Steps not done yet
    squareYellow="\033[0;33m\xE2\x96\x88\033[0m"
}

create_directory () {
	# Check if directories exists. If not, create them.
	if [[ ! -d $@ ]]; then
	mkdir -pv $@
    fi
}

get_boot_type () {
    # Determine if UEFI or BIOS boot. If /sys/firmware/efi exists --> UEFI boot
    if [ -d "/sys/firmware/efi" ]; then
        boot='uefi'
    else
        boot='bios'
    fi
}

get_terminal_width () {
    terminalWidth=$(tput cols)
}

load_keymap () {
    loadkeys $1
}

print_center_text () {
    # TODO Implement functionality to check if given text is to long
    # to be displayed in one line. If so, split text at special character
    # or space and move it to next line.

    # Assign given values to variables
    borderCharacter="$1"
    text="$2"
    # Get terminal width
    get_terminal_width
    # Subtract the number of characters of the text string from the terminal
    # width to get the number of colums available for border characters and
    # padding.
    terminalWidthMinusText=$(((terminalWidth - ${#text})))
    # Subtract two columns for the border characters on each side and divide
    # by two to get the padding on one side. Assign it to two separate variables
    # to manipulate them independently if necessary.
    paddingLeft=$((((terminalWidthMinusText - 2) / 2)))
    paddingRight=$paddingLeft
    # Check if the remaining columns after inserting the text is uneven. If yes,
    # increase paddingLeft by 1 to avoid to be one character short on the right
    # end.
    if [ $((terminalWidthMinusText % 2)) == 1 ]; then
        ((paddingLeft++))
    fi
    # Print border character as left border
    printf "$borderCharacter"
    # Print left padding, so for each column one space character
    for (( i=0; i < $paddingLeft; i++ )); do
        printf " "
    done
    # Print text
    printf "$text"
    # Print right padding
    for (( i=0; i < $paddingRight; i++ )); do
        printf " "
    done
    # Print border character as right corner
    printf "$borderCharacter"
    # Print new line character to make sure the cursor is in a new line
    printf "\n"
}

print_heading () {
    # Assign given values to variables
    borderCharacter="$1"
    padding="$2"
    heading="$3"
    # Get terminal width
    get_terminal_width
    # Subtract the number of characters of the header string from the terminal
    # width to get the number of colums available for border characters and
    # padding.
    terminalWidthMinusHeading=$(((terminalWidth - ${#heading})))
    # Subtract the columns of the two paddings on each side and divide
    # by two to get the border width on one side. Assign it to two separate 
    # variables to manipulate them independently if necessary.
    borderLeft=$((((terminalWidthMinusHeading - 2 * padding) / 2)))
    borderRight=$borderLeft
    # Check if the remaining columns after inserting the heading is uneven. 
    # If yes, increase paddingLeft by 1 to avoid to be one character short on 
    # the right end.
    if [ $((terminalWidthMinusHeading % 2)) == 1 ]; then
        ((borderLeft++))
    fi
    # Print left border, for each column one border character
    for (( i=0; i < $borderLeft; i++ )); do
        printf "$borderCharacter"
    done
    # Print left padding
    for (( i=0; i < $padding; i++ )); do
        printf " "
    done
    # Print heading
    printf "$heading"
    # Print right padding
    for (( i=0; i < $padding; i++ )); do
        printf " "
    done
    # Print right border
    for (( i=0; i < $borderRight; i++ )); do
        printf "$borderCharacter"
    done
    # Print new line character to make sure the cursor is in a new line
    printf "\n"
}

print_head_message () {
    # Set ouput color
    set_color $cyan
    # Print line as upper border of text box
    print_line "#"
    # Print content of text box
    print_center_text "#" "ArmoredGoat's Artix Installation Script"
    print_center_text "#" "Last updated: 2023/06/04"
    # Print line as lower border of text box
    print_line "#"
    # Reset output color
    set_color $colorOff
    # Save current cursor position
	tput sc

    text="\nBefore installation, a few questions have to be answered."
    prompt="Press any key to continue."
    echo -e "$text"
    read -n 1 -sp $'\n'"$prompt"
    # Return to cursor position and clear everything on screen below
	tput rc
	tput ed
}

print_line () {
    # Assign given value to variable
    fillingCharacter="$1"
    # Get terminal width
    get_terminal_width
    # For each column print the filling character
    for (( i=0; i < $terminalWidth; i++ )); do
        printf "$fillingCharacter"
    done
    # Print new line character to make sure the cursor is in a new line
    printf "\n"
}

set_color () {
    printf "$1"
}

set_manual_configuration () {
    set_color $purple
    print_heading "#" 3 "CONFIGURATION"

    set_installation_type    
}

set_installation_type () {
    set_color $blue
    print_heading "#" 3 "INSTALLATION TYPE"

}

##########   START MANUAL CONFIGURATION

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

for mountPoint in $(mount | grep "^$baseDisk" | awk '{print $3}'); do
    umount -fl $mountPoint
done

# In case of UEFI boot --> GPT/UEFI partitioning with 1 GiB disk space 
# for boot partition
# In case of BIOS boot --> MBR/BIOS partitioning
if [ "$boot" == 'uefi' ]; then
    wipefs --all --force "$baseDisk"

    # To create partitions programatically (rather than manually)
    # the following is going to simulate the manual input to fdisk.
    # sed strips off all comments so that documentation can be included
    # without interfering with the input.
    # Blank lines (commented as "Defualt") will send an empty
    # line terminated with a newline to take the fdisk default.
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk -w always -W always "$baseDisk"
        g       # Create new GPT disklabel
        n       # New partition
        1       # Partition number 1
                # Default - Start at beginning of disk
        +1024M  # 1 GiB boot parttion
        t       # Set type of partiton
        1       # Set type to 'EFI System'
        n       # New partition
        2       # Partition number 2
                # Default - Start at beginning of remaining disk
        +$swap  # Partiton size equal to given swap value
        t       # Set type of partiton
        2       # Select partition 2
        19      # Set type to 'Linux Swap'
        n       # New partition
        3       # Partition number 3
                # Default - start at beginning of remaining disk
                # Default - use remaining disk space
        w       # Write partition table
        q       # Quit fdisk
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
    wipefs --all --force "$baseDisk"
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk -w always -W always "$baseDisk"
    g       # Create new GPT disklabel
    n       # New partition
    1       # Partition number 1
            # Default - Start at beginning of disk
    +1M     # 1 MB BIOS boot partition
    t       # Set type of partiton
    4       # Set type to 'BIOS boot'
    n       # New partition
    2       # Partition number 2
            # Default - Start at beginning of remaining disk
    +$swap  # Partiton size equal to given swap value
    t       # Set type of partiton
    2       # Select partition 2
    19      # Set type to 'Linux Swap'
    n       # New partition
    3       # Partition number 3
            # Default - start at beginning of remaining disk
            # Default - use remaining disk space
    w       # Write partition table
    q       # Quit fdisk
EOF

    # Format and label disks
    mkswap -L SWAP "$disk"'2'
    
    mkfs.ext4 -L ROOT "$disk"'3'

    # Mount storage and EFI partitions, and create necessary directories
    swapon "$disk"'2'
    mount "$disk"'3' /mnt
    
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
kernel="linux"

# Firmware
    # linux-firmware    -
    # sof-firmware      -
firmware="linux-firmware"

# Network
network="connman connman-$initSystem wpa_supplicant wpa_supplicant-$initSystem"

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
echo "$installationType" > /mnt/tempfiles/installationType
echo "$baseDisk" > /mnt/tempfiles/baseDisk
echo "$username" > /mnt/tempfiles/username
echo "$userPassword" > /mnt/tempfiles/userPassword
echo "$setRootPassword" > /mnt/tempfiles/setRootPassword
echo "$rootPassword" > /mnt/tempfiles/rootPassword
echo "$timezone" > /mnt/tempfiles/timezone

##########   END EXPORTING VARIABLES

curl $downloadUrl/chrootInstall.sh -o /mnt/chrootInstall.sh
chmod +x /mnt/chrootInstall.sh
artix-chroot /mnt /chrootInstall.sh

echo -e "\n##############################################################################################"
echo -e "#                                   ${Green}Installation completed                                   ${Color_Off}#"
echo -e "#                Make sure to ${Red}remove installation media${Color_Off} before powering back on              #"
echo -e "##############################################################################################"

while true; do
    read -n 1 -sp $'\n'"Press RETURN to reboot the system now or any other key \
to exit the script without rebooting." reboot
    case $reboot in
        "")
            delete_term_lines 1 1

            umount -R /mnt  # Unmounts disk
            reboot
            
            break
            ;;
        *)
            delete_term_lines 1 1

            break
            ;;
    esac      
done

# Call main function
main