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
    print_welcome_message
    # Get hardware and boot information
    get_system_information
    # Run manual configuration
    set_manual_configuration
    # Partition chosen disk
    partition_disk
    # Generate filesystem table
    generate_filesystem_table
    # Set hostname
    set_hostname
    # Activate NTP daemon to synchronize computer's real-time clock
    start_service ntpd

    install_general_packages

    export_variables

    download_chroot_install_script

    execute_chroot_install_script

    print_ciao_message
}

create_directory () {
	# Check if directories exists. If not, create them.
	if [[ ! -d $@ ]]; then
	mkdir -pv $@
    fi
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
    gray='\033[0;90m'         # gray
}

declare_special_characters () {
    # Set variables to special characters to indicate status of step
    # Green = Accepted inputs/done steps
    squareGreen="\033[0;32m\xE2\x96\x88\033[0m"
    # Red = Denied inputs/canceled steps
    squareRed="\033[0;31m\xE2\x96\x88\033[0m"
    # YellowRead = Waiting for input
    squareYelR=$'\033[0;33m\xE2\x96\x88\033[0m'
    # Yellow = Steps not done yet
    squareYellow="\033[0;33m\xE2\x96\x88\033[0m"
}

delete_terminal_lines () {
    # Function to control cursor and delete terminal output. This is a
    # subsitution for tput sc/rc, because it does not seem to function inside
    # my script.

    # \r jumps to beginning of line
    # \033 marks beginning of escape sequence
    # [1A moves one line up
    # [0K erase from cursor to right end
    local ERASE_CURR="\r\033[0K"
    local ERASE_PREV="\r\033[1A\033[0K"
    local MOVE_CURSOR_UP="\033[1A"
    local ERASE_STRING=""
    # If set, erase current line
    if [[ $2 ]]; then
        ERASE_STRING+="${ERASE_CURR}"
    fi
    # If set, erase given number of previous lines
    for (( i=0; i < $1; i++ )); do
        ERASE_STRING+="${ERASE_PREV}"
    done
    # If set, move cursor one line up
    if [[ $3 ]]; then
        ERASE_STRING+="${MOVE_CURSOR_UP}"
    fi
    # Output string to make changes
    printf "${ERASE_STRING}"
}

download_chroot_install_script () {
    curl $downloadUrl/chrootInstall.sh -o /mnt/chrootInstall.sh
}

execute_chroot_install_script () {
    chmod +x /mnt/chrootInstall.sh
    artix-chroot /mnt /chrootInstall.sh
}

export_variables () {
    pathVariables="/mnt/tempfiles"
    create_directory $pathVariables

    variables=("cpu" "threadsMinusOne" "gpu" "boot" "installationType" \
        "baseDisk" "username" "userPassword" "setRootPassword" "rootPassword" \
        "timezone")

    for variable in ${variables[@]}; do
        echo ${!variable} > $pathVariables/$variable
        printf "\nVariable exported:\t$variable\n"
    done
}

generate_filesystem_table () {
    fstabgen -U /mnt >> /mnt/etc/fstab
}

get_boot_type () {
    # Determine if UEFI or BIOS boot. If /sys/firmware/efi exists --> UEFI boot
    if [ -d "/sys/firmware/efi" ]; then
        boot='uefi'
    else
        boot='bios'
    fi
}

get_hardware_information () {
    # Get CPU to install according packages in chrootInstall.sh if necessary
    cpu=$(lscpu | grep 'Vendor ID:' | awk 'FNR == 1 {print $3;}')
# Temporarily disables as I don't have a usecase for this yet.
#    threadsMinusOne=$(( $(lscpu | grep 'CPU(s):' | \
#        awk 'FNR == 1 {print $2;}') - 1 ))
    # Get GPU to install according drivers in chrootInstall.sh if necessary
    gpu=$(lspci | grep 'VGA compatible controller:' | awk 'FNR == 1 {print $5;}')
    # Sometimes, AMD is called AuthenticAMD. To match package names, set gpu to 
    # 'AMD' if it is not NVIDIA, Intel or VMware
    if ! ([ "$gpu" == 'NVIDIA' ] || [ "$gpu" == 'Intel' ] || \
        [ "$gpu" == 'VMware' ]); then
            gpu='AMD'
    fi
    # Get amount of RAM
    ram=$(echo "$(< /proc/meminfo)" | grep 'MemTotal:' | awk '{print $2;}')
    # Convert RAM from byte into gigabyte
    ram=$(( $ram / 1000000 ))
}

get_system_information () {
    get_boot_type
    get_hardware_information
}

get_terminal_width () {
    terminalWidth=$(tput cols)
}

install_general_packages () {
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

    generalPackages="$basePackages $initSystem $loginManager $kernel $firmware $network"

    install_packages $generalPackages
}

install_packages () {
    basestrap /mnt $@
}

load_keymap () {
    loadkeys $1
}

partition_disk () {
    # Check if SWAP is mounted. If yes, unmount it.
    swapDevice=$(cat /proc/swaps | grep "partition" | awk '{print $1}')
    if [[ $swapDevice ]]; then
        swapoff $swapDevice
    fi
    # In case of NVME or SD/MMC device, append 'p' to adress Linux' 
    # way of naming partitions.
    baseDisk=$disk
    if [[ "$disk" == /dev/nvme0n* ]] || [[ "$disk" == /dev/mmcblk* ]]; then
        disk="$disk"'p'
    fi
    # Unmount any partition of chosen disk that is mounted.
    for mountPoint in $(mount | grep "^$baseDisk" | awk '{print $3}'); do
        umount -fl $mountPoint
    done
    # In case of UEFI boot --> GPT/UEFI partitioning with 1 GiB disk space 
    # for boot partition
    # In case of BIOS boot --> MBR/BIOS partitioning
    if [ "$boot" == 'uefi' ]; then
        # Wipe any existing partition tables and filesystem on disk
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
        # Format and label EFI partition
        mkfs.fat -F 32 "$disk"'1'
        fatlabel "$disk"'1' ESP
        # Format and label SWAP partition
        mkswap -L SWAP "$disk"'2'
        # Format and label ROOT partition
        mkfs.ext4 -L ROOT "$disk"'3'
        # Mount SWAP partition
        swapon "$disk"'2'
        # Mount ROOT partition
        mount "$disk"'3' /mnt
        # Create necessary directories on mounted disk
        mkdir -p /mnt/{boot,boot/efi,etc/conf.d,home}
        # Mount EFI partition
        mount  "$disk"'1' /mnt/boot/efi
    else # If BIOS boot
        # Wipe any existing partition tables and filesystem on disk
        wipefs --all --force "$baseDisk"
        # Create partition table
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
        # Format and label SWAP partition
        mkswap -L SWAP "$disk"'2'
        # Format and label ROOT partition
        mkfs.ext4 -L ROOT "$disk"'3'
        # Mount SWAP partition
        swapon "$disk"'2'
        # Mount ROOT partition
        mount "$disk"'3' /mnt
        # Create necessary directories
        mkdir -p /mnt/etc/conf.d
    fi
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

print_ciao_message () {
    printf "\n"
    set_color $cyan
    print_line "#"
    print_center_text "#" "Installation completed!"
    print_center_text "#" "Please remove installation media before powering back on."
    print_line "#"
    set_color $colorOff

    while true; do
        prompt="Press RETURN to reboot system or any other key to exit script."
        read -n 1 -sp $'\n'"$prompt" reboot
        case $reboot in
            "")
                delete_terminal_lines 0 1
                umount -R /mnt  # Unmounts disk
                reboot
                
                break
                ;;
            *)
                delete_terminal_lines 0 1

                break
                ;;
        esac      
    done
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
    # Print new line to have an empty line above heading
    printf "\n"
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

print_welcome_message () {
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


    text="\nBefore installation, a few questions have to be answered."
    prompt="Press any key to continue."
    printf "$text"
    read -n 1 -sp $'\n'"$prompt"

    delete_terminal_lines 2 0 1
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

set_confirmation () {
    set_color $purple
    print_heading "#" 5 "CONFIGURATION"
    set_color $colorOff


    # Ask for confirmation to continue with installation
    while true; do
        printf "\n"
        prompt="Proceed installation with given information (y/N)? "
        read -p $squareYelR$'\t'"$prompt" proceed
        case $proceed in
            [yY][eE][sS]|[yY])
                delete_terminal_lines 1
                break
                ;;
            [nN][oO]|[nN]|"")
                # Delete output
                delete_terminal_lines 2
                # Inform user that the script will be aborted
                printf "\n${squareRed}\tThe installation will be aborted.\n"
                read -sp $'\n\t'"Press any key to exit."
                # Print empty line for spacing
                printf "\n\n"
                # Exit script
                exit 0
                ;;
            *)
                # Delete output
                delete_terminal_lines 1
                # Inform user that the input was invalid and wait two seconds
                printf "${squareRed}\tInvalid input..."
                sleep 2
                # Delete output
                delete_terminal_lines 1
                ;;
        esac      
    done
}

set_disk () {
    # Set output color
    set_color $gray
    # Print heading of section
    print_heading "#" 15 "DISK SELECTION"
    # Reset output color
    set_color $colorOff

    # List available disks with their partitions and store output in temp file
    printf "\n$(lsblk --tree | grep 'NAME\|disk\|part')" | tee /tempfiles/output
    # Count number of lines of temp file to track number of printed lines
    numberOfLines=$(wc -l < /tempfiles/output)

    # Store available disks in temp file, enumerates them, and display choices
    (lsblk --list -d | grep disk | awk '{print NR") /dev/" $1}') > \
        /tempfiles/availableDisks
    # Print empty lines for spacing
    printf "\n\n"

    # Print lines of temp file
    while IFS= read -r line; do
        printf "$line\n"
    done < /tempfiles/availableDisks

    # Get number of lines of temp file = number of available disks
    numberOfDisks=$(wc -l < /tempfiles/availableDisks)

    # Ask which disk shall be paritioned
    while true; do
        # Print empty line for spacing
        printf "\n"
        # Adjust prompt to number of available disks
        if [[ "$numberOfDisks" > "1" ]]; then
            prompt="Which disk shall be partitioned (1-$numberOfDisks)? "
            read -p $squareYelR$'\t'"$prompt" selectedDisk
        else
            prompt="Which disk shall be partitioned (1)? "
            read -p $squareYelR$'\t'"$prompt" selectedDisk
        fi
        # Check if given value has a according disk. If yes, leave while loop
        if (( 1 <= $selectedDisk && $selectedDisk <= $numberOfDisks )); then
            # Set disk
            disk=$(sed "${selectedDisk}q;d" /tempfiles/availableDisks | \
                awk '{print $2}')
            # Delete output
            delete_terminal_lines $(( $numberOfLines + 5 ))
            break
        else
            # Delete output
            delete_terminal_lines 1
            # Inform user that the input was invalid and wait two seconds
            printf "${squareRed}\tInvalid input..."
            sleep 2
            # Delete output
            delete_terminal_lines 1
        fi    
    done
    # Confirm disk selection
    printf "\n${squareGreen}\tDisk ${disk} selected.\n"

    # Ask for confirmation to wipe selected disk.
    while true; do
        # Print empty line for spacing
        printf "\n"
        prompt="${disk} will be completely wiped. Continue (y/N)? "
        read -p $squareYelR$'\t'"$prompt" wipe
        case $wipe in
            [yY][eE][sS]|[yY])
                # Delete output
                delete_terminal_lines 2
                # Leave while loop
                break
                ;;
            [nN][oO]|[nN]|"")
                # Delete output
                delete_terminal_lines 2
                # Inform user that the script will be aborted
                printf "\n${squareRed}\tThe installation will be aborted.\n"
                read -sp $'\n\t'"Press any key to exit."
                # Print empty line for spacing
                printf "\n\n"
                # Exit script
                exit 0
                ;;
            *)
                # Delete output
                delete_terminal_lines 1
                # Inform user that the input was invalid and wait two seconds
                printf "${squareRed}\tInvalid input..."
                sleep 2
                # Delete output
                delete_terminal_lines 1
                ;;
        esac      
    done
}

set_manual_configuration () {
    set_color $purple
    print_heading "#" 5 "CONFIGURATION"

    set_installation_type  

    set_color $blue
    print_heading "#" 10 "PARTITIONING"

    set_disk
    set_swap

    set_color $blue
    print_heading "#" 10 "SYSTEM SETTINGS"

    set_host_settings
    set_user_settings

    set_timezone

    set_confirmation
}

set_hostname () {
    # Insert hostname into /etc/hostname
    printf $hostname > /mnt/etc/hostname
    # Insert 
    printf "hostname='$hostname'" > /mnt/etc/conf.d/hostname
}

set_host_settings () {
    # Set output color
    set_color $gray
    # Print heading of section
    print_heading "#" 15 "HOST SETTINGS"
    # Reset output color
    set_color $colorOff

    printf "\n${squareYellow}\tSetting username...\n"

    read -rp $'\nHostname: ' hostname
    delete_terminal_lines 4
    # Change uppercase characters to lowercase
    hostname=$(echo "$hostname" | tr '[:upper:]' '[:lower:]')
    # Confirm hostname
    printf "\n${squareGreen}\tHostname '${hostname}' set!\n"
}

set_installation_type () {
    # Set output color
    set_color $blue
    # Print heading of section
    print_heading "#" 10 "INSTALLATION TYPE"
    # Declare and print informational text
    textBaseInstallation="${green}1) Base installation${colorOff} \
        \n\tOnly necessary packages and configuration. \
        \n\tIn the end you have a working but basic Artix installation."
    textCustomizedInstallation="\n${green}2) Custom installation${colorOff} \
        \n\tTake over all my configuration and user settings. \
        \n\tIt is not guaranteed that my configuration is one hundred percent \
        \n\tcompatible with your system."
    printf "\n$textBaseInstallation"
    printf "\n$textCustomizedInstallation\n"
    # Ask for prefered installation type.
    while true; do
        printf "\n"
        read -p $squareYelR$'\t'"Choose installation type (1-2)? " \
            installationType
        # If given value has according installation type, leave while loop.
        # Otherwise, reenter.
        case $installationType in
            1)
                # Delete output
                delete_terminal_lines 11
                # Set installation type
                installationType='base'
                # Leave while loop
                break
                ;;
            2)
                # Delete output
                delete_terminal_lines 11
                # Set installation type
                installationType='custom'
                # Leave while loop
                break
                ;;
            *)
                # Delete output
                delete_terminal_lines 1
                # Inform user that the input was invalid and wait two seconds
                printf "${squareRed}\tInvalid input..."
                sleep 2
                # Delete output
                delete_terminal_lines 1
                ;;
        esac      
    done
    # Confirm chosen installation type.
    printf "\n${squareGreen}\tInstallation type '${installationType}' set!\n"
}

set_root_password () {
    while true; do
        printf "\n"
        read -p $squareYelR$'\t'"Do you want to set a root password (y/N)? " \
            setRootPassword
        case $setRootPassword in
            [yY][eE][sS]|[yY])
                # Delete output
                delete_terminal_lines 1 0 1
                
                printf "\n${squareYellow}\tSetting root password...\n"

                # Declare placeholder values to first enter while loop
                rootPassword="foo"; rootPasswordConf="bar"

                while [[ $rootPassword != $rootPasswordConf ]]; do
                    read -rsp $'\nRoot password: ' rootPassword
                    delete_terminal_lines 0 1
                    read -rsp $'Confirm root password: ' rootPasswordConf
                    # Check if passwords match and are long enough
                    if [[ $rootPassword != $rootPasswordConf && \
                            ${#rootPassword} < 8 ]]; then
                        # Delete output
                        delete_terminal_lines 1 1
                        # Inform user that passwords are too short and do not match
                        printf "\n${squareRed}\tPasswords do not match AND too short (>=8)."
                        # Wait three seconds
                        sleep 3
                        # Delete output
                        delete_terminal_lines 1 1
                    # Check if passwords match and are long enough
                    elif [[ $rootPassword == $rootPasswordConf && \
                    ${#rootPassword} < 8 ]]; then
                        # Delete output
                        delete_terminal_lines 1 1
                        # Inform user that passwords are too short
                        printf "\n${squareRed}\tPasswords are too short (>=8)."
                        # Wait three seconds
                        sleep 3
                        # Reset passwords to reenter while loop.
                        rootPassword="foo"; rootPasswordConf="bar"
                        # Delete output
                        delete_terminal_lines 1 1
                    # Check if passwords match
                    elif [[ $rootPassword != $rootPasswordConf ]]; then
                        # Delete output
                        delete_terminal_lines 1 1
                        # Inform user that passwords do not match
                        printf "\n${squareRed}\tPasswords do not match."
                        # Wait three seconds
                        sleep 3
                        # Delete output
                        delete_terminal_lines 1 1
                    else # Password do match and are long enough
                        # Delete output
                        delete_terminal_lines 2 1 1
                        # Leave while loop
                        break
                    fi
                done
                # Set variable
                setRootPassword=true
                # Confirm root password is set
                printf "\n${squareGreen}\tRoot password set.\n"
                # Leave while loop
                break
                ;;
            [nN][oO]|[nN]|"")
                # Set variable
                setRootPassword=false
                # Delete output
                delete_terminal_lines 2
                # Confirm that no root password is set
                printf "\n${squareGreen}\tNo root password set.\n"
                # Leave while loop
                break
                ;;
            *)
                # Delete output
                delete_terminal_lines 1
                # Inform user that the input was invalid and wait two seconds
                printf "${squareRed}\tInvalid input..."
                sleep 2
                # Delete output
                delete_terminal_lines 1
                ;;
        esac      
    done
}

set_swap () {
    # Set output color
    set_color $gray
    # Print heading of section
    print_heading "#" 15 "SWAP SPACE"
    # Reset output color
    set_color $colorOff
        
    # Ask how much swap space should be allocated and convert the value
    # from Gibibyte to Megabyte.
    printf "\n${squareYellow}\tSetting size of swap space...\n"

    read -rp $'\nSwap size in GiB: ' swap
    # Delete outpu
    delete_terminal_lines 4
    # Confirm chosen swap size.
    printf "\n${squareGreen}\t${swap} GiB swap space set!\n"
    
    # Convert size of swap space from gibibyte to megabyte to be compatible
    # with partiton table
    swap="$(( $swap * 1024 ))"'M'
}

set_timezone () {
    # Set output color
    set_color $gray
    # Print heading of section
    print_heading "#" 15 "TIME SETTINGS"
    # Reset output color
    set_color $colorOff

    printf "\n${squareYellow}\tSetting time zone...\n"

    printf "\n"

    printf "1) Africa \n2) America \n3) Asia \n4) Atlantic \n5) Australia \
        \n6) Europe \n7) Pacific \n8) Etc \n" | tee /tempfiles/regions
    numberOfRegions="$(wc -l < /tempfiles/regions)"

    while true; do
        printf "\n"
        prompt="Please enter your region's number (1-$numberOfRegions): "
        read -p $squareYelR$'\t'"$prompt" regionNumber

        if (( 1 <= $regionNumber && $regionNumber <= $numberOfRegions )); then
            region=$((sed "${regionNumber}q;d" /tempfiles/regions) | \
                awk '{print $2}')

            delete_terminal_lines 11

            break
        else
            # Delete output
            if [[ $regionNumber == "" ]]; then
                delete_terminal_lines 2
            else
                delete_terminal_lines 1
            fi
            # Inform user that the input was invalid and wait two seconds
            printf "${squareRed}\tInvalid input..."
            sleep 2
            # Delete output
            delete_terminal_lines 1
        fi
    done

    printf "\n${squareYellow}\t${region} selected...\n\n"

    ls -l /usr/share/zoneinfo/$region | grep -v "\->" | \
    tail -n +2 > /tempfiles/regionCities
    numberOfCities="$(wc -l < /tempfiles/regionCities)"

    ls -l /usr/share/zoneinfo/$region | grep -v "\->" | tail -n +2 | \
    awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output
    numberOfOutputLines=$(wc -l < /tempfiles/output)

    while true; do
        printf "\n"
        if [[ $numberOfCities > "1" ]]; then
            prompt="Please enter your cities' number (1-$numberOfCities): "
        else
            prompt="Please enter your cities' number (1): "
        fi
        read -p $squareYelR$'\t'"$prompt" cityNumber
        if (( 1 <= $cityNumber && $cityNumber <= $numberOfCities )); then
            city=$(sed "${cityNumber}q;d" /tempfiles/regionCities | \
            awk '{print $9}')

            delete_terminal_lines $(( $numberOfOutputLines + 5 ))

            break
        else
            # Delete output
            if [[ $cityNumber == "" ]]; then
                delete_terminal_lines 2
            else
                delete_terminal_lines 1
            fi
            # Inform user that the input was invalid and wait two seconds
            printf "${squareRed}\tInvalid input..."
            sleep 2
            # Delete output
            delete_terminal_lines 1
        fi 
    done

    if [[ -d /usr/share/zoneinfo/$region/$city ]]; then

        printf "\n${squareYellow}\t${region}/${city} selected...\n\n"

        ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | \
        tail -n +2 > /tempfiles/regionSubCities
        numberOfSubCities="$(wc -l < /tempfiles/regionSubCities)"

        ls -l /usr/share/zoneinfo/$region/$city | grep -v "\->" | tail -n +2 | \
        awk '{print NR") " $9}' | column -c $(tput cols) | tee /tempfiles/output

        while true; do
            printf "\n"
            if [[ "$numberOfSubCities" > "1" ]]; then
                prompt="Please enter your cities' number (1-$numberOfSubCities): "
            else
                prompt="Please enter your cities' number (1): "
            fi
                read -p $squareYelR$'\t'"$prompt" subCityNumber
            if (( 1 <= $subCityNumber && $subCityNumber <= $numberOfCities )); then
                subCity=$(sed "${subCityNumber}q;d" /tempfiles/regionSubCities | \
                awk '{print $9}')
                
                delete_terminal_lines 8
                
                break
            else
            # Delete output
            if [[ $subCityNumber == "" ]]; then
                delete_terminal_lines 2
            else
                delete_terminal_lines 1
            fi
            # Inform user that the input was invalid and wait two seconds
            printf "${squareRed}\tInvalid input..."
            sleep 2
            # Delete output
            delete_terminal_lines 1 
            fi 
        done

    else
        delete_terminal_lines 2

    fi

    if [ $subCity ]; then
        timezone="$region/$city/$subCity"
    else
        timezone="$region/$city"
    fi

    # Confirm time zone
    printf "\n${squareGreen}\tTime zone '${timezone}' set!\n"
}

set_username () {
    printf "\n${squareYellow}\tSetting username...\n"

    read -rp $'\nUsername: ' username
    # Delete output
    delete_terminal_lines 4

    # Change uppercase characters to lowercase
    username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
    # Confirm username
    printf "\n${squareGreen}\tUsername '${username}' set!\n"
}

set_user_password () {
    printf "\n${squareYellow}\tSetting user password...\n"
    
    # Declare placeholder values to first enter while loop
    userPassword="foo"; userPasswordConf="bar"

    while [ $userPassword != $userPasswordConf ]; do
        read -rsp $'\nUser password: ' userPassword
        # Delete output
        delete_terminal_lines 0 1
        read -rsp $'Confirm user password: ' userPasswordConf
        # Check if passwords match and are long enough
        if [[ $userPassword != $userPasswordConf && \
                ${#userPassword} < 8 ]]; then
            # Delete output
            delete_terminal_lines 1 1
            # Inform user that passwords are too short and do not match
            printf "\n${squareRed}\tPasswords do not match AND too short (>=8)."
            # Wait three seconds
            sleep 3
            # Delete output
            delete_terminal_lines 1 1
        # Check if passwords match and are long enough
        elif [[ $userPassword == $userPasswordConf && ${#userPassword} < 8 ]]; then
            # Delete output
            delete_terminal_lines 1 1
            # Inform user that passwords are too short
            printf "\n${squareRed}\tPasswords are too short (>=8)."
            # Wait three seconds
            sleep 3
            # Reset passwords to reenter while loop.
            userPassword="foo"; userPasswordConf="bar"
            # Delete output
            delete_terminal_lines 1 1
        # Check if passwords match
        elif [[ $userPassword != $userPasswordConf ]]; then
            # Delete output
            delete_terminal_lines 1 1
            # Inform user that passwords do not match
            printf "\n${squareRed}\tPasswords do not match."
            # Wait three seconds
            sleep 3
            # Delete output
            delete_terminal_lines 1 1
        else # Password do match and are long enough
            # Delete output
            delete_terminal_lines 2 1 1
            # Leave while loop
            break
        fi
    done
    # Confirm user password.
    printf "\n${squareGreen}\tUser password set.\n"
}

set_user_settings () {
    # Set output color
    set_color $gray
    # Print heading of section
    print_heading "#" 15 "USER SETTINGS"
    # Reset output color
    set_color $colorOff

    set_username
    set_user_password

    set_root_password
}

start_service () {
    # Set service to given package/service
    service="$1"

    # Start service
    rc-service $service start

    # TODO Add support for other init system
    #  sv up ntpd   s6-rc -u change ntpd   dinitctl start ntpd 
}

main
