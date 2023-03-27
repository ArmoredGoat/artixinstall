#! /bin/bash

loadkeys us
echo "##############################################################################################"
echo "#                          ArmoredGoat's Artix Installation Script                           #"
echo "#                                 Last updated at 2023/03/20                                 #"
echo "#        Educationally inspired by https://github.com/rwinkhart/artix-install-script         #"
echo "##############################################################################################"

echo "Before installation, a few question have to be answered."
read -n 1 -srp "Press any key to continue."

#####   START MANUAL CONFIGURATION  #####

# List available disks
printf "\nAvailable disks\n"
lsblk --tree | grep 'NAME\|disk\|part'

# Store available disks in temp file, enumerates them, and display choices
(lsblk --list -d | grep disk | awk '{print NR") /dev/" $1}') > /tempfiles/availableDisks
while IFS= read -r line; do
    echo $line
done < /tempfiles/availableDisks

# Get number of lines of temp file = number of choices
numberOfDisks=$(wc -l < /tempfiles/availableDisks)
# Disk can be selected by entering its number 
while true; do
    if [[ "$numberOfDisks" > 1 ]]; then
        read -rp "Which disk shall be partitioned? [1 - $(numberOfDisks)]" selectedDisk
    else
        read -rp "Which disk shall be partitioned? [1]" selectedDisk
    fi
      case $selectedDisk in
        [1-$numberOfDisks])
            disk=$(sed "${selectedDisk}q;d" /tempfiles/availableDisks | awk '{print $2}')
            break
            ;;
        *)
            echo "Invalid input. Please choose one of the available disks listed above by entering its number."
            ;;
      esac      
done

# Ask for confirmation to wipe selected disk.
while true; do
    read -rp "The selected disk will be completely wiped. Do you want to continue? (y/N)" wipe
    case $wipe in
        [yY][eE][sS]|[yY])
            break
            ;;
        [nN][oO]|[nN]|"")
            echo "The installation will be aborted. Exiting process..."
            exit 0
            ;;
        *)
            echo "Invalid input..."
            ;;
    esac      
done
# Ask how much swap space should be allocated and convert the value from Gibibyte to Megabyte.
read -rp "Swap size in GiB: " swap; swap="$(( $swap * 1024 ))"'M'

# Ask for hostname and credentials. Ensuring that passwords match.
read -rp "Hostname: " hostname
read -rp "Username: " username

userPassword="foo"; userPasswordConf="bar"
while [[ $userPassword != $userPasswordConf ]]; do
    read -rsp "User password: " userPassword
    read -rsp "Confirm user password: " userPasswordConf
    if [ $userPassword != $userPasswordConf ]; then
        echo "Passwords does not match. Please repeat."
    else
        break
    fi
done

while true; do
    read -rp "Do you want to set a root password? (y/N)" setRootPassword
    case $setRootPassword in
        [yY][eE][sS]|[yY])
            setRootPassword=true
            rootPassword="foo"; rootPasswordConf="bar"
            while [[ $rootPassword != $rootPasswordConf ]]; do
                read -rsp "Root password: " rootPassword
                read -rsp "Confirm root password: " rootPasswordConf
                if [ $rootPassword != $rootPasswordConf ]; then
                    echo "Passwords does not match. Please repeat."
                else
                    break
                fi
            done
            break
            ;;
        [nN][oO]|[nN]|"")
            setRootPassword=false
            echo "No root password will be set."
            break
            ;;
        *)
            echo "Invalid input..."
            ;;
    esac      
done




# TODO Implement selection of timezone.
timezone="Europe/Berlin" # Temporarily hard coded

#####   END MANUAL CONFIGURATION    #####

#####   START HARDWARE DETECTION    #####

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

#####   END HARDWARE DETECTION      #####

#####   START CONDITIONAL QUERIES   #####

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

#####   END CONDITIONAL QUERIES     #####

#####   START VARIABLE MANIPULATION #####

# Change uppercase characters to lowercase for username and hostname
username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
hostname=$(echo "$hostname" | tr '[:upper:]' '[:lower:]')

#####   END VARIABLE MANIPULATION   #####

#####   START PARTITIONING          #####

# In case of UEFI boot --> GPT/UEFI partitioning with 1 GiB disk space for boot partition.
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

#####   END PARTITIONING            #####

#####   START BASE INSTALLATION     #####

# Generate filesystem table
fstabgen -U /mnt >> /mnt/etc/fstab

# Set hostname
echo "$hostname" > /mnt/etc/hostname
echo "hostname=\'"$hostname"\'" > /mnt/etc/conf.d/hostname

# Install packages
# TODO Add explanation to choice of packages
# Base packages
    # base          - 
    # base-devel    - Package group with tools for building (compiling and linking) software
    #base_devel='db diffutils gc guile libisl libmpc perl autoconf automake bash binutils bison esysusers /tempfilesfiles fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman pacman-contrib patch pkgconf python sed opendoas texinfo which bc udev'
basePackages='base base-devel'

# Init system
    # openrc    - 
initSystem='openrc'

# Login manager
    # elogind   - 
loginManager='elogind-'$initSystem

# Linux kernel
    # linux-lts, zen, ...
kernel='linux-lts'

# Firmware
    # linux-firmware    -
    # sof-firmware      -
firmware='linux-firmware sof-firmware'

# Network
    # networkmanager                -
    # networkmanager-$initSystem    -
    # dhcpcd                        -
    # iwd                           -
network='networkmanager-'$initSystem' dhcpcd'

# Editor
    # vim   -
editor='vim'

# Manuals
    # man-db    -
    # man-pages -
    # texinfo   -
manuals='man-db man-pages texinfo'

# General administration
    # sudo
generalAdministration='sudo'

# Filesystem adiminstration
    # e2fsprogs -
    # dosfstools    -
filesystemAdministration='e2fsprogs dosfstools'

# Additional packages
    # git   -
    # micro -
    # bash-completion   -
additionalPackages='git micro bash-completion'

basestrap /mnt $basePackages $initSystem $loginManager $kernel $firmware $generalAdministration $editor $manuals $network $filesystemAdministration $additionalPackages

#####   END BASE INSTALLATION       #####

#####   START EXPORTING VARIABLES   #####

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

#####   END EXPORTING VARIABLES     #####

curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/main/chrootInstall.sh -o /mnt/chrootInstall.sh
chmod +x /mnt/chrootInstall.sh
artix-chroot /mnt /chrootInstall.sh