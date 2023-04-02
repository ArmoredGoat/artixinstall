
#####   START IMPORTING VARIABLES   #####

#echo "$formfactor"="$(< /tempfiles/formfactor)"
echo "$cpu"="$(< /tempfiles/cpu)"
echo "$threadsMinusOne"="$(< /tempfiles/threadsMinusOne)"
echo "$gpu"="$(< /tempfiles/gpu)"
#echo "$intel_vaapi_driver"="$(< /tempfiles/intel_vaapi_driver
echo "$boot"="$(< /tempfiles/boot)"
echo "$baseDisk"="$(< /tempfiles/disk)"
echo "$username"="$(< /tempfiles/username)"
echo "$userPassword"="$(< /tempfiles/userPassword)"
echo "$setRootPassword"="$(< /tempfiles/setRootPassword)"
echo "$rootPassword"="$(< /tempfiles/rootPassword)"
echo "$timezone"="$(< /tempfiles/timezone)"

#####   END IMPORTING VARIABLES     #####

#####   START CONFIGURATION         #####

# Configure localization
# Enable desired locale by uncommenting line
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

# Set desired locale systemwide
echo 'LANG=¨en_US.UTF-8"' > /etc/locale.conf
# Set collation rules (rules for sorting and regular expresions)
# C - dotfiles first, followed by uppercase and lowercase filenames
echo 'LC_COLLATE="C"' >> /etc/locale.conf
# Set time zone
ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime
# Generate locales
locale-gen

# Activate NTP daemon to synchronize computer's real-time clock
rc-service ntpd start
#  sv up ntpd   s6-rc -u change ntpd   dinitctl start ntpd

# Configure clock settings
hwclock --systohc --utc

# Enable network manager
rc-update add NetworkManager

#####   END CONFIGURATION           #####

#####   START GRUB INSTALLATION     #####

# Install grub
    # grub - 
    # efibootmgr - 
    # os-prober - Detection of other installed operating systems
pacman -S grub efibootmgr os-prober --noconfirm

# Check if BIOS or UEFI boot and install grub accordingly
if [ "$boot" == 'uefi' ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
    # grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB-rwinkhart --recheck
    # TODO Learn about bootloader-id
fi
if [ "$boot" == 'bios' ]; then
    grub-install --target=i386-pc "$disk"
fi

# TODO Learn what the heck is going on right here...

#cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
#curl https://raw.githubusercontent.com/rwinkhart/artix-install-script/main/config-files/grub -o /etc/default/grub
#if [ "$gpu" == 'NVIDIA' ]; then
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone" nvidia-drm.modeset=1\"" >> /etc/default/grub
#elif [ "$gpu" == 'AMD' ]; then
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone" amdgpu.ppfeaturemask=0xffffffff\"" >> /etc/default/grub
#else
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone"\"" >> /etc/default/grub
#fi

# Create grub configuration in boot directory
grub-mkconfig -o /boot/grub/grub.cfg

#####   END GRUB INSTALLATION       #####

#####   START USER MANAGEMENT       #####

# Set root password if given. Otherwise disable access.
if [ "$setRootPassword" =true ]; then
    echo "$rootpassword
    $rootpassword
    " | passwd
else
    usermod -p '!' root
fi

# Create user and set password
useradd -m "$username"
echo "$userPassword
$userPassword
" | passwd "$username"

# Grant groups to user
usermod -aG wheel,audio,video,storage "$username"
# Give users in wheel group sudo privileges --> no need for root user
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//g' /etc/sudoers

# set home directory permissions
mkdir -p /home/"$username"/{.config,.local/share}
chmod 700 /home/"$username"
chown "$username":users /home/"$username"/{.config,.local}
chown "$username":users /home/"$username"/.local/share
chmod 755 /home/"$username"/{.config,.local/share}

mkdir -p /home/"$username"/git/{own,cloned}


#####   END USER MANAGEMENT         #####
if [[ "$installationType" == "custom" ]]; then
    curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/tree/main/configfiles/user-dirs.defaults -o /etc/xdg/user-dirs.defaults

    ##### START GRAPHIC DRIVERs INSTALLATION    #####

    if [ "$gpu" == 'AMD' ]; then
        $graphicsDrivers='xf86-video-amdgpu mesa lib32-mesa vulkan-radeon'
    elif [ "$gpu" == 'INTEL' ]; then
        $graphicsDrivers='xf86-video-intel mesa lib32-mesa vulkan-intel'
    elif [ "$gpu" == 'NVIDIA' ]; then
        $graphicsDrivers='xf86-video-nouveau mesa lib32-mesa nvidia-utils'
    elif [ "$gpu" == 'VMware' ]; then
        $graphicsDrivers='xf86-video-vmware xf86-input-vmmouse mesa lib32-mesa'
    fi

    pacman -S $graphicsDrivers --needed --noconfirm

    xorgPackages='xorg xorg-server xorg-xinit'

    pacman -S $xorgPackages --needed --noconfirm

    #####   END GRAPHIC DRIVERs INSTALLATION    #####

    #####   START WM INSTALLATION   #####

    # Might switch from awesome to qtile as it is completely written in python
    wm='awesome' # qtile

    pacman -S $wm --needed --noconfirm

    # TODO Add configuration

    #####   END WM INSTALLATION     #####

    pacman -S neofetch --noconfirm

    # TODO Add neofetch configuration


    pacman -S alacritty --noconfirm

    # TODO Add alacritty configuration

    # Install AUR helper
    git clone https://aur.archlinux.org/yay-git.git /home/"$username"/git/cloned/yay
    cd /home/"$username"/git/cloned/yay
    sudo -u "$username" makepkg -si

    # Install browser
    echo "1
    " | gpg --keyserver hkp://keyserver.ubuntu.com --search-keys 031F7104E932F7BD7416E7F6D2845E1305D6E801   # Import gpg key
    git clone https://aur.archlinux.org/librewolf-bin.git /home/"$username"/git/cloned/librewolf
    cd /home/"$username"/git/cloned/librewolf
    sudo -u "$username" makepkg -si

    # Application configuration

    # Xorg



    # vim
    #curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/tree/main/configfiles/user-dirs.defaults -o /etc/xdg/user-dirs.defaults

    # $filesystemAdministration $additionalPackages $generalAdministration $editor

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
    additionalPackages='git micro bash-completion sof-firmware'
fi

exit
umount -R /mnt
reboot