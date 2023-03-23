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

(lsblk --list -d | grep disk | awk '{print NR") /dev/" $1}') > /tmp/diskstemp

while IFS= read -r line; do
    echo $line
done < /tmp/diskstemp

linesnumber=$(wc -l < tempfile)

while true
do
      read -rp "Which disk shall be partitioned? " disk
      case $disk in
            [1-$linesnumber])
                  disk=$(sed "${disk}q;d" /tmp/diskstemp | awk '{print $2}')
                  break
                  ;;
            *)
                  echo "Invalid input. Please choose one of the available disks listed above."
                  ;;
      esac      
done

read -rp "Swap size in GB: " swap

while true
do
      read -n 1 -rp "Do you want to perform a clean install? (y/N)" wipe
      case $wipe in
            [yY][eE][sS]|[yY])
                  wipe='y'
                  break
                  ;;
            [nN][oO]|[nN]|"")
                  wipe='n'
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

disk0=$disk
if [[ "$disk" == /dev/nvme0n* ]] || [[ "$disk" == /dev/mmcblk* ]]; then
    disk="$disk"'p'
fi

# determine if running as UEFI or BIOS
# If /sys/firmware/efi exists it is an UEFI boot
if [ -d "/sys/firmware/efi" ]; then
    boot='uefi'
else
    boot='bios'
fi

# start partitioning
if [ "$boot" == 'uefi' ]; then
    # gpt/uefi partitioning
    if [ "$wipe" == y ]; then
        partitions=0
        wipefs --all --force "$disk0"
        echo "g
        n
        1

        +1024M
        t
        1
        n
        2

        +8192M
        t
        2
        19
        n
        3

        
        w
        " | fdisk -w always -W always "$disk0"
        #part 1 = boot, part 2 = swap, part 3 = root

        # disk formatting
        mkfs.fat -F 32 "$disk""$((1 + "$partitions"))"
        fatlabel "$disk""$((1 + "$partitions"))" ESP
        mkswap -L SWAP "$disk""$((2 + "$partitions"))"
        mkfs.ext4 -L ROOT "$disk""$((3 + "$partitions"))"

    else
        partitions=$(lsblk "$disk0" -o NAME | grep -o '.$' | tail -1)
        echo "n
        +1024M
        t
        1
        n
        w
        " | fdisk -W always "$disk0"
    fi


    # mounting storage and efi partitions
    swapon /dev/disk/by-label/SWAP
    mount /dev/disk/by-label/ROOT /mnt
    mkdir /mnt/boot
    mkdir /mnt/home
    if [ "$boot" == 'uefi' ]; then
        mkdir -p /mnt/{boot/EFI,etc/conf.d}
        mount /dev/disk/by-label/ESP /mnt/boot/efi
    fi
    
else
    # mbr/bios partitioning
    if [ "$wipe" == y ]; then
        partitions=0
        echo "o
        n
        p
        w
        " | fdisk -w always -W always "$disk0"
    else
        partitions=$(lsblk "$disk0" -o NAME | grep -o '.$' | tail -1)
        echo "n
        p
        w
        " | fdisk -W always "$disk0"
    fi

    # disk formatting
    mkfs.ext4 -O fast_commit "$disk""$((1 + "$partitions"))"

    # mounting storage (no efi partition, using dos label)
    mount "$disk""$((1 + "$partitions"))" /mnt
    mkdir -p /mnt/etc/conf.d
fi

fstabgen -U /mnt >> /mnt/etc/fstab

# setting hostname
echo "$hostname" > /mnt/etc/hostname
echo "hostname=\'"$hostname"\'" > /mnt/etc/conf.d/hostname

# installing base packages
#base_devel='db diffutils gc guile libisl libmpc perl autoconf automake bash binutils bison esysusers etmpfiles fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman pacman-contrib patch pkgconf python sed opendoas texinfo which bc udev'
basestrap /mnt base base_devel openrc elogind-openrc linux-lts linux-firmware git micro man-db bash-completion

# exporting variables
mkdir /mnt/tempfiles
echo "$formfactor" > /mnt/tempfiles/formfactor
echo "$cpu" > /mnt/tempfiles/cpu
echo "$threadsminusone" > /mnt/tempfiles/threadsminusone
echo "$gpu" > /mnt/tempfiles/gpu
echo "$intel_vaapi_driver" > /mnt/tempfiles/intel_vaapi_driver
echo "$boot" > /mnt/tempfiles/boot
echo "$disk0" > /mnt/tempfiles/disk
echo "$username" > /mnt/tempfiles/username
echo "$password" > /mnt/tempfiles/userpassword
echo "$rootpassword" > /mnt/tempfiles/rootpassword
echo "$timezone" > /mnt/tempfiles/timezone

#curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/main/chrootInstall.sh -o /mnt/chrootInstall.sh
#chmod +x /mnt/chrootInstall.sh
#artix-chroot /mnt /chrootInstall.sh