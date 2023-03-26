
#####   START IMPORTING VARIABLES   #####

#echo "$formfactor"="$(< /mnt/tmp/formfactor)"
echo "$cpu"="$(< /mnt/tmp/cpu)"
echo "$threadsMinusOne"="$(< /mnt/tmp/threadsMinusOne)"
echo "$gpu"="$(< /mnt/tmp/gpu)"
#echo "$intel_vaapi_driver"="$(< /mnt/tmp/intel_vaapi_driver
echo "$boot"="$(< /mnt/tmp/boot)"
echo "$baseDisk"="$(< /mnt/tmp/disk)"
echo "$username"="$(< /mnt/tmp/username)"
echo "$userPassword"="$(< /mnt/tmp/userPassword)"
echo "$rootPassword"="$(< /mnt/tmp/rootPassword)"
echo "$timezone"="$(< /mnt/tmp/timezone)"

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

if [ -n "$rootPassword" ]; then
    echo "$rootpassword
    $rootpassword
    " | passwd
else
    usermod -p '!' root
fi

useradd -m "$username"
echo "$userPassword
$userPassword
" | passwd "$username"

usermod -aG wheel,audio,video,storage "$username"

sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//g' /etc/sudoers



#####   END USER MANAGEMENT         #####