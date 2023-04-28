#! /bin/bash

##########  START COLORS   

# Reset
colorOff='\033[0m'       # Text Reset

# Colors
blue='\033[0;34m'         # blue
purple='\033[0;35m'       # purple
cyan='\033[0;36m'         # cyan
red='\033[0;31m'          # red
green='\033[0;32m'        # green

##########  END COLORS

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

##########  START IMPORTING VARIABLES

#echo "$formfactor"="$(< /tempfiles/formfactor)"
cpu="$(< /tempfiles/cpu)"
threadsMinusOne="$(< /tempfiles/threadsMinusOne)"
gpu="$(< /tempfiles/gpu)"
#"$intel_vaapi_driver"="$(< /tempfiles/intel_vaapi_driver
boot="$(< /tempfiles/boot)"
installationType="$(< /tempfiles/installationType)"
baseDisk="$(< /tempfiles/baseDisk)"
username="$(< /tempfiles/username)"
userPassword="$(< /tempfiles/userPassword)"
setRootPassword="$(< /tempfiles/setRootPassword)"
rootPassword="$(< /tempfiles/rootPassword)"
timezone="$(< /tempfiles/timezone)"

##########  END IMPORTING VARIABLES

##########  START CONFIGURATION

# Configure localization
# Enable desired locale by uncommenting line
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

# Set desired locale systemwide
echo 'export LANG="en_US.UTF-8"' > /etc/locale.conf
# Set collation rules (rules for sorting and regular expresions)
# C - dotfiles first, followed by uppercase and lowercase filenames
echo 'export LC_COLLATE="C"' >> /etc/locale.conf
# Set time zone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
# Generate locales
locale-gen

# Configure clock settings
hwclock --systohc --utc

# Enable network manager
rc-update add NetworkManager

##########  END CONFIGURATION

##########  START GRUB INSTALLATION

# Install grub
    # grub - 
    # efibootmgr - 
    # os-prober - Detection of other installed operating systems
pacman -Syuq grub efibootmgr os-prober --needed --noconfirm

# Check if BIOS or UEFI boot and install grub accordingly
if [ "$boot" == 'uefi' ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
    # grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB-rwinkhart --recheck
    # TODO Learn about bootloader-id
fi
if [ "$boot" == 'bios' ]; then
    grub-install --target=i386-pc --recheck $baseDisk
fi

# TODO Learn what the heck is going on right here...

#cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
#curl https://raw.githubusercontent.com/rwinkhart/artix-install-script/iss005/config-files/grub -o /etc/default/grub
#if [ "$gpu" == 'NVIDIA' ]; then
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone" nvidia-drm.modeset=1\"" >> /etc/default/grub
#elif [ "$gpu" == 'AMD' ]; then
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone" amdgpu.ppfeaturemask=0xffffffff\"" >> /etc/default/grub
#else
#    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet nowatchdog retbleed=off mem_sleep_default=deep nohz_full=1-"$threadsminusone"\"" >> /etc/default/grub
#fi

# Create grub configuration in boot directory
grub-mkconfig -o /boot/grub/grub.cfg

##########  END GRUB INSTALLATION

##########  START USER MANAGEMENT

# Set root password if given. Otherwise disable access.
if [ "$setRootPassword" = true ]; then
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
# Disable sudo password prompts for this user
echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# set home directory permissions
mkdir -p /home/"$username"/{.config,.local/share}
chmod 750 /home/"$username"
chmod 755 /home/"$username"/{.config,.local/share}

##########  END USER MANAGEMENT

##########  START GENERAL PACKAGE INSTALLATION

# Manuals
    # man-db    -
    # man-pages -
    # texinfo   -
    manuals="man-db man-pages texinfo"

# General administration
    # sudo
    generalAdministration="sudo"

# Filesystem adiminstration
    # e2fsprogs -
    # dosfstools    -
    filesystemAdministration="e2fsprogs dosfstools"

pacman -Syuq $manuals $generalAdministration $filesystemAdministration --needed --noconfirm

##########  END GENERAL PACKAGE INSTALLATION

##########  START INSTALLATION TYPE SPEFIFIC INSTALLATION AND CONFIGURATION

if [[ $installationType == 'base' ]]; then 

    # Editor
        # nano  -
    editor='nano'

    pacman -Syuq $editor --needed --noconfirm

elif [[ $installationType == 'custom' ]]; then

    ### PACMAN

        # Get config files repository and store them in corresponding directory
        # Download pacman.conf with additional repositories and access to the Arch repositories
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/pacman/pacman.conf -o /etc/pacman.conf

        if [[ ! -d /etc/pacman.d ]]; then
            mkdir -p /etc/pacman.d
        fi

        # Get recent mirror lists
        curl https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/pacman-mirrorlist/trunk/mirrorlist -o /etc/pacman.d/mirrorlist-arch

        # Uncomment every mirror temporarily to download reflector
        sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch

        # Install and enable support of Arch repositories
        pacman -Syuq artix-archlinux-support --needed --noconfirm
        # Retrieve keys
        pacman-key --populate archlinux

        ### REFLECTOR

            # reflector -
            pacman -Syuq reflector --needed --noconfirm

            # Run reflector to select the best five servers for my country
            reflector --save /etc/pacman.d/mirrorlist-arch --country Germany --protocol https --latest 5

            # Get config files repository and store them in corresponding directory
            # Add file reflector.start to local.d directory to run reflector at start without systemd
            curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/local.d/reflector.start -o /etc/local.d/reflector.start
            # Make reflector.start executable
            chmod +x /etc/local.d/reflector.start

    #TODO add paccache to cron

    ### BASH

        # Get config files repository and store them in corresponding directory
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/bash/.bashrc -o /home/"$username"/.bashrc
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/bash/.bash_aliases -o /home/"$username"/.bash_aliases

        source /home/"$username"/.bashrc

        chmod +x /home/"$username"/.bash*

        pacman -Syuq bash-completion --needed --noconfirm

    ### XDG

        pacman -Syuq xdg-user-dirs --needed --noconfirm

        if [[ ! -d /etc/xdg ]]; then
            mkdir -p /etc/xdg
        fi

        # Get config files repository and store them in corresponding directory
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/xdg/user-dirs.defaults -o /etc/xdg/user-dirs.defaults

        mkdir -p /home/"$username"/{downloads,documents/{music,public,desktop,templates,pictures,videos}}

    ### CRON

        pacman -Syuq cronie cronie-openrc --needed --noconfirm
        rc-update add cronie
        rc-service cronie start

    ### SSH

        pacman -Syuq openssh openssh-openrc --needed --noconfirm
        rc-update add sshd
        rc-service sshd start

    ### FIREWALL

        # ufw - 
        #pacman -Syuq ufw ufw-openrc --needed --noconfirm
        
        # Enable ufw to start on boot
        #rc-update add ufw

        # Disable any traffic by default
        #ufw default deny

        # Activate logging
        #ufw logging low

        # Limit SSH connections
        #ufw limit ssh comment 'Limit Connections On SSH Port'

        # Allow traffic from home network and specific ports/protocols
        #ufw allow from 192.168.1.0/24
        
        #ufw allow in 25,53,80,123,143,443,465,587,993/tcp comment 'Standard Incomming Ports'
        #ufw allow out 22,25,53,80,123,143,443,587,993/tcp comment 'Standard Outgoing Ports'
        #ufw allow in 53,123/udp comment 'Allow NTP and DNS in'
        #ufw allow out 53,123/udp comment 'Allow NTP and DNS out'

        # https://hackspoiler.de/ufw-linux-server-firewall-skript/
        #TODO Explain ports
        #TODO If email client is used, add ports of outgoing servers
        # https://askubuntu.com/questions/448836/how-do-i-with-ufw-deny-all-outgoing-ports-excepting-the-ones-i-need

        # Reload ufw
        #ufw --force enable

    ### LOCAL
    
        # Make sure that local service is running
        rc-update add local
        rc-service local start

    ### GRUB

        # Disable grub delay to speed up boot process
        # If grub menu is needed, press ESC while booting

        # Find and replace 'menu' with 'hidden'
        sed -i 's/GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/g' \
        /etc/default/grub

        # Update grub config
        grub-mkconfig -o /boot/grub/grub.cfg
        
    ### EDITOR
        
        pacman -Syuq neovim --needed --noconfirm

    ### TERMINAL EMULATOR

        pacman -Syuq kitty --needed --noconfirm

        if [[ ! -d /home/"$username"/.config/kitty ]]; then
            mkdir -p /home/"$username"/.config/kitty
        fi

        ## General configuration
        # Get config files repository and store them in corresponding directory
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/kitty/kitty.conf \
        -o /home/"$username"/.config/kitty/kitty.conf
        ## Configure theme
        if [[ ! -d /home/"$username"/.config/kitty/themes ]]; then
            mkdir -p /home/"$username"/.config/kitty/themes
        fi

        # Download them from https://github.com/kovidgoyal/kitty-themes
        curl https://raw.githubusercontent.com/kovidgoyal/kitty-themes/master/themes/Earthsong.conf \
        -o /home/"$username"/.config/kitty/themes/Earthsong.conf
        ln -s /home/"$username"/.config/kitty/themes/Earthsong.conf \
            /home/"$username"/.config/kitty/theme.conf


    ### GIT

        pacman -Syuq git --needed --noconfirm

        # Create directory for git repositories
        mkdir -p /home/"$username"/git/{own,cloned}
        chmod 755 /home/"$username"/git/{own,cloned}
        chown -R "$username":"$username" /home/"$username"/git/{own,cloned}

    ### AUR HELPER
    
        runuser -l "$username" -c "git clone https://aur.archlinux.org/yay.git \
        /home/$username/git/cloned/yay && cd /home/$username/git/cloned/yay && \
        makepkg -si --noconfirm"

        # Generate development package database for *-git packages that were
        # installed without yay
        runuser -l "$username" -c "yay -Y --gendb --noconfirm"
        # Check for development packages updates
        runuser -l "$username" -c "yay -Syu --devel --noconfirm"
        # Enable development packages updates and combined upgrades permanently
        runuser -l "$username" -c "yay -Y --devel --combinedupgrade /
        --batchinstall --save --noconfirm"

    ### BROWSER

        pacman -Syuq firefox-esr --needed --noconfirm

    ### NEOFETCH

        pacman -Syuq neofetch --needed --noconfirm
        #TODO Add neofetch configuration

    ### AUDIO

        pacman -Rs jack2
        pacman -Syuq pipewire lib32-pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack pipewire-docs wireplumber pavucontrol --needed --noconfirm

        if [[ ! -d /home/"$username"/.config/pipewire ]]; then
            mkdir -p /home/"$username"/.config/pipewire
        fi

        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/pipewire/pipewire.conf -o /home/"$username"/.config/pipewire/pipewire.conf
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/pipewire/.pipewire-start.sh -o /home/"$username"/.config/pipewire/.pipewire-start.sh
        chmod +x /home/"$username"/.config/pipewire/.pipewire-start.sh

    ### FIRMWARE & FUNCTIONALITY

        pacman -Syuq sof-firmware --needed --noconfirm

        if [[ $cpu == 'AuthenticAMD' ]]; then
            microcodePackage='amd-ucode'
        elif [[ $cpu == 'Intel' ]]; then
            microcodePackage='intel-ucode'
        fi 

        #https://averagelinuxuser.com/arch-linux-after-install/#7-install-microcode
        pacman -Syuq $microcodePackage --needed --noconfirm

    ### GRAPHIC DRIVERS

        # Install drivers depending on detected gpu
        if [ "$gpu" == 'AMD' ]; then
            $graphicsDrivers='xf86-video-amdgpu mesa lib32-mesa vulkan-radeon'
        elif [ "$gpu" == 'INTEL' ]; then
            $graphicsDrivers='xf86-video-intel mesa lib32-mesa vulkan-intel'
        elif [ "$gpu" == 'NVIDIA' ]; then
            $graphicsDrivers='xf86-video-nouveau mesa lib32-mesa nvidia-utils'
        elif [ "$gpu" == 'VMware' ]; then
            $graphicsDrivers='xf86-video-vmware xf86-input-vmmouse mesa lib32-mesa'
        fi

        pacman -Syuq $graphicsDrivers --needed --noconfirm

    ### DISPLAY SERVER

        pacman -Syuq xorg xorg-server xorg-xinit --needed --noconfirm

        # Get config files repository and store them in corresponding directory
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/xorg/.xinitrc -o /home/"$username"/.xinitrc
        chmod +x /home/"$username"/.xinitrc
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/xorg/xorg.conf -o /etc/X11/xorg.conf

    ### LOGIN MANAGER

        # lightdm
        # lightdm-openrc
        # lightdm-gtk-greeter
        # light-locker
        pacman -Syuq lightdm lightdm-openrc light-locker lightdm-gtk-greeter --needed --noconfirm

        # Enable sddm to start at boot
        rc-update add lightdm

        # Create directory for sddm config files
        if [[ ! -d /etc/lightdm ]]; then
            mkdir -p /etc/lightdm
        fi

        # Get config files repository and store them in corresponding directory
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/lightdm/lightdm.conf -o /etc/lightdm/ligthdm.conf
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/lightdm/lightdm-gtk-greeter.conf -o /etc/lightdm/ligthdm-gtk-greeter.conf
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/lightdm/users.conf -o /etc/lightdm/users.conf
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/lightdm/Xsession -o /etc/lightdm/Xsession
        curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/iss005/configfiles/xorg/.xprofile -o /home/"$username"/.xprofile
        chmod +x /home/"$username"/.xprofile

    ### WINDOW MANAGER

        pacman -Syuq qtile nitrogen picom --needed --noconfirm

        if [[ ! -d /home/"$username"/.config/backgrounds ]]; then
            mkdir -p /home/"$username"/.config/backgrounds
        fi



        #TODO Add configuration

    ### YOUTUBE TUI
    
        #pacman -Syuq jq mpv fzf yt-dlp imv
        #git clone 
    
fi

# Change ownership of all installed files above from root to user.
chown -R "$username":"$username" /home/"$username"

##########  END INSTALLATION TYPE SPEFIFIC INSTALLATION AND CONFIGURATION

# Finish up and remove (temporary) files

rm -rf /chrootInstall.sh /tempfiles

exit
