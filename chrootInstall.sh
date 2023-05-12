#! /bin/bash

baseUrlRaw="https://raw.githubusercontent.com"
gitRepo="ArmoredGoat/artixinstall"
gitBranch="iss005"
downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"

##########  START FUNCTIONS

create_directory () {
	# Check if directories exists. If not, create them.
	if [[ ! -d $@ ]]; then
	mkdir -pv $@
    fi
	# This script is run with privileged rights. Therefore, anything created
	# with it will be owned by root. To make sure that the permissions are set
	# correclty, the function checks if the directory lies in the home folder.
	# If so, it grants ownership to the user.
	if [[ $@ = $homedir/* ]]; then
		# General permissions settings. If necessary, e.g. ssh keys, the
        # permissions will be set accordingly
        chmod 755 $@
		chown -R "$username":"$username" $@
	fi
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

homedir=/home/"$username"

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

# Enable and start connman
rc-update add connmand
rc-service connmand start

##########  END CONFIGURATION

##########  START GRUB INSTALLATION

# Install grub
    # grub - 
    # efibootmgr - 
    # os-prober - Detection of other installed operating systems
pacman -Syu grub efibootmgr os-prober --needed --noconfirm

# Check if BIOS or UEFI boot and install grub accordingly
if [ "$boot" == 'uefi' ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi \
        --bootloader-id=grub --recheck
    # grub-install --target=x86_64-efi --efi-directory=/boot/EFI \
    #    --bootloader-id=GRUB-rwinkhart --recheck
    # TODO Learn about bootloader-id
fi
if [ "$boot" == 'bios' ]; then
    grub-install --target=i386-pc --recheck $baseDisk
fi

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
chmod 750 /home/"$username"
create_directory $homedir/{.config,.local/share}

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

pacman -Syu $manuals $generalAdministration $filesystemAdministration \
    --needed --noconfirm

##########  END GENERAL PACKAGE INSTALLATION

##########  START INSTALLATION TYPE SPEFIFIC INSTALLATION AND CONFIGURATION

if [[ $installationType == 'base' ]]; then 

    # Editor
        # nano  -
    editor='nano'

    pacman -Syu $editor --needed --noconfirm

elif [[ $installationType == 'custom' ]]; then

    ## ESSENTIALS

    ### FIRMWARE

        pacman -Syu sof-firmware --needed --noconfirm

        if [[ $cpu == 'AuthenticAMD' ]]; then
            microcodePackage='amd-ucode'
        elif [[ $cpu == 'Intel' ]] || [[ $cpu == 'GenuineIntel' ]]; then
            microcodePackage='intel-ucode'
        fi 

        #
        pacman -Syu $microcodePackage --needed --noconfirm

    ### JAVA

        pacman -Syu jdk17-openjdk --needed --noconfirm

    ### PYTHON

        pacman -Syu python python-pip --needed --noconfirm

        create_directory /home/"$username"/.local/lib

        runuser -l "$username" -c "pip3 install --user setuptools"
    
    ### PACMAN

        # Get config files repository and store them in corresponding directory
        # Download pacman.conf with additional repositories and access to the 
        # Arch repositories
        curl $downloadUrl/dotfiles/pacman/pacman.conf \
            -o /etc/pacman.conf
	
	create_directory /etc/pacman.d

        # Get recent mirror lists
        archSvnRepo="archlinux/svntogit-packages/packages"
        curl $baseUrlRaw/$archSvnRepo/pacman-mirrorlist/trunk/mirrorlist \
            -o /etc/pacman.d/mirrorlist-arch

        # Uncomment every mirror temporarily to download reflector
        sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch

        # Install and enable support of Arch repositories
        pacman -Syu artix-archlinux-support --needed --noconfirm
        # Retrieve keys
        pacman-key --populate archlinux

        ### REFLECTOR

            # reflector -
            pacman -Syu reflector --needed --noconfirm

            # Run reflector to select the best five servers for my country
            reflector --save /etc/pacman.d/mirrorlist-arch --country Germany \
                --protocol https --latest 5

            # Get config files repository and store them in corresponding 
            # directory. Add file reflector.start to local.d directory to run 
            # reflector at start without systemd
            curl $downloadUrl/dotfiles/local.d/reflector.start \
                -o /etc/local.d/reflector.start
            # Make reflector.start executable
            chmod +x /etc/local.d/reflector.start
            #TODO add paccache to cron
        
        ### ADDITIONALS

        pacman -Syu pacman-contrib --needed --noconfirm

    ### VERSION CONTROL SYSTEM

        pacman -Syu git --needed --noconfirm

        # Create directory for git repositories
        create_directory $homedir/git/{own,cloned}

    ### AUR HELPER

        runuser -l "$username" -c "git clone https://aur.archlinux.org/yay.git \
            $homedir/git/cloned/yay && \
            cd $homedir/git/cloned/yay && \
            makepkg -si --noconfirm"

        # Generate development package database for *-git packages that were
        # installed without yay
        runuser -l "$username" -c "yay -Y --gendb --noconfirm"
        # Check for development packages updates
        runuser -l "$username" -c "yay -Syu --devel --noconfirm"
        # Enable development packages updates and combined upgrades permanently
        runuser -l "$username" -c "yay -Y --devel --combinedupgrade \
            --batchinstall --save --noconfirm"

    ### XDG

        pacman -Syu xdg-user-dirs --needed --noconfirm
	
	create_directory /etc/xdg

        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/xdg/user-dirs.defaults \
            -o /etc/xdg/user-dirs.defaults

	create_directory $homedir/{downloads,documents/{music,public,desktop,templates,pictures,videos}}

    ## INTERNET

    ### CLOUD SYNCHRONIZATION

        pacman -Syu nextcloud-client --needed --noconfirm

    ### EMAIL CLIENT

        pacman -Syu neomutt --needed --noconfirm

    ### INSTANT MESSAGING

    #### MULTI-PROTOCOL CLIENT

        pacman -Syu weechat --needed --noconfirm

    #### OTHER INSTANT MESSAGING CLIENTS

        pacman -Syu discord --needed --noconfirm

    ### NETWORK MANAGER

        # See install.sh. connman and wpa_supplicant are being used.

    ### VPN CLIENT

        pacman -Syu wireguard-tools wireguard-openrc --needed --noconfirm

        #rc-update add wireguard
        #rc-service wireguard start

    ### WEB BROWSER

        pacman -Syu firefox-esr --needed --noconfirm

    ## MULTIMEDIA

    ### AUDIO

        pacman -Rdd jack2 --noconfirm
        pacman -Syu pipewire lib32-pipewire pipewire-audio pipewire-alsa \
            pipewire-pulse pipewire-jack pipewire-docs wireplumber pavucontrol \
            --needed --noconfirm

	create_directory $homedir/.config/pipewire

        curl $downloadUrl/dotfiles/pipewire/pipewire.conf \
            -o $homedir/.config/pipewire/pipewire.conf
        curl $downloadUrl/dotfiles/pipewire/.pipewire-start.sh \
            -o $homedir/.config/pipewire/.pipewire-start.sh
        chmod +x $homedir/.config/pipewire/.pipewire-start.sh

    ### AUDIO PLAYER

        pacman -Syu cmus --needed --noconfirm

    ### AUDIO TAG EDITOR

        pacman -Syu beets --needed --noconfirm

    ### AUDIO VISUALIZER

        runuser -l "$username" -c "yay -Syu cli-visualizer-git \
            --needed --noconfirm"

    ### IMAGE VIEWER

        pacman -Syu imv --needed --noconfirm

    ### OPTICAL DISK RIPPING

        # Installing makemkv-cli requires to accept the EULA, which pops up
        # before finishing the process. The pager 'less' is used to display
        # the text. To automatically leave less the command line option
        # LESS='+q' is given along. Then it behaves as 'q' was entered manually.
        # "yes 'yes'" outputs a constant stream of 'yes' strings 
        # followed by a new line. This way as soon as the script leaves the
        # pager, it accepts the EULA.
        runuser -l "$username" -c "yes 'yes' | LESS='+q' yay -Syu makemkv-cli \
            --needed --noconfirm"

    ### SCREENSHOTS

        pacman -Syu flameshot --needed --noconfirm
    
    ### VIDEO PLAYER

        pacman -Syu mpv --needed --noconfirm

    ### VIDEO EDITOR

        runuser -l "$username" -c "yay -Syu losslesscut-bin \
            --needed --noconfirm"

    ### WEBCAM

        pacman -Syu cameractrls --needed --noconfirm

    ##  UTILITY

    ### ARCHIVE MANAGER

        pacman -Syu p7zip --needed --noconfirm

    ### AUR HELPER

        # See section ESSENTIALS above.

    ### BACKUP

        # See SYNCHRONIZATION below. 

    ### BLUETOOTH MANAGEMENT

    pacman -Syu bluez bluez-openrc bluez-utils --needed --noconfirm

    ### BOOT MANAGEMENT

        # Disable grub delay to speed up boot process
        # If grub menu is needed, press ESC while booting

        # Find and replace 'menu' with 'hidden'
        sed -i 's/GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/g' \
        /etc/default/grub

        # Update grub config
        grub-mkconfig -o /boot/grub/grub.cfg

    ### CLOCK SYNCHRONIZATION

        # connman's native ntp service is used.

    ### COMMAND-LINE SHELL

        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/bash/.bashrc \
            -o $homedir/.bashrc
        curl $downloadUrl/dotfiles/bash/.bash_aliases \
            -o $homedir/.bash_aliases

        source $homedir/.bashrc

        chmod +x $homedir/.bash*

        pacman -Syu bash-completion --needed --noconfirm

    ### FILE MANAGER

        pacman -Syu ranger --needed --noconfirm

    ### JOB SCHEDULER

        pacman -Syu cronie cronie-openrc --needed --noconfirm
        rc-update add cronie
        rc-service cronie start

        # Make sure that local service is running
        rc-update add local
        rc-service local start

    ### MANUALS

        pacman -Syu man-db man-pages texinfo --needed --noconfirm

    ### PAGER

        pacman -Syu less --needed --noconfirm

    ### SECURE SHELL

        pacman -Syu openssh openssh-openrc --needed --noconfirm
        rc-update add sshd
        rc-service sshd start

    ### SYNCHRONIZATION

        pacman -Syu rsync rsync-openrc --needed --noconfirm

    ### SYSLOGS

        pacman -Syu syslog-ng syslog-ng-openrc --needed --noconfirm
        rc-update add syslog-ng
        rc-service syslog-ng start

    ### SYSTEM INFORMARTION VIEWER

        pacman -Syu fastfetch --needed --noconfirm

    ### TASK MANAGER

        pacman -Syu bottom --needed --noconfirm
        
    ### TERMINAL EMULATOR

        pacman -Syu kitty --needed --noconfirm
	
        # Create directories for kitty's general configs
        create_directory $homedir/.config/kitty

        # Create directories for personal backgrounds, fonts, themes, etc.
        create_directory $homedir/.local/share/{backgrounds,fonts,themes}

        ## General configuration
        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/kitty/kitty.conf \
            -o $homedir/.config/kitty/kitty.conf

        ## Configure font

        # Create directory for fonts in home directory and download font to it.
        # This way kitty can see it as an available font to use.
        create_directory $homedir/.fonts/pt_mono

        curl $downloadUrl/dotfiles/fonts/PTMono-Regular.ttf \
            -o $homedir/.local/share/fonts/pt_mono/pt_mono_regular.ttf

    ### TRASH MANAGEMENT

        pacman -Syu trash-cli --needed --noconfirm

        # Create cron job to delete all files that are trashed longer than
        # 90 days on a daily basis. The '2>/dev/null' is necessary to
        # surpress 'no crontab for username' message.
        (crontab -l 2>/dev/null ; echo "@daily $(which trash-empty) 90") \
            | crontab -

    ### VERSION CONTROL SYSTEM

        # See section ESSENTIALS above.

    ### VIRTUALIZATION

        pacman -Rdd iptables --noconfirm
        pacman -Syu virt-manager qemu-desktop qemu-guest-agent-openrc \
            dnsmasq iptables-nft --needed --noconfirm

        # Set UNIX domain socket ownership to libvirt and permissions to read
        # and write by uncommenting the following lines

        sed -i '/unix_sock_group = /s/^#//g' /etc/libvirt/libvirtd.conf
        sed -i '/unix_sock_rw_perms = /s/^#//g' /etc/libvirt/libvirtd.conf

        usermod -aG libvirt "$username"

        sed sed -i "s/user = \"libvirt-qemu\"/user = \"$username\"/" \
            /etc/libvirt/libvirtd.conf
        sed sed -i "s/group = \"libvirt-qemu\"/group = \"$username\"/" \
            /etc/libvirt/libvirtd.conf

    ## DOCUMENTS

    ### TEXT EDITOR EDITOR
        
        pacman -Syu neovim --needed --noconfirm

    ## GAMING

    ### GAME DISTRIBUTION PLATFORM

        pacman -Syu steam --needed --noconfirm

    ### MINECRAFT LAUNCHER

#        # Build dependencies
#        pacman -Syu qt6 ninja cmake extra-cmake-modules zlib\
#            --needed --noconfirm
#        git clone --recursive https://github.com/Diegiwg/PrismLauncher-Cracked.git \
#            $homedir/git/cloned/prismlauncher
#        cd $homedir/git/cloned/prismlauncher
#
#        cmake -S . -B build -G Ninja \
#            -DCMAKE_BUILD_TYPE=Release \
#            -DCMAKE_INSTALL_PREFIX="/usr" \
#            -DENABLE_LTO=ON \
#            -DLauncher_QT_VERSION_MAJOR="6"
#
#        cmake --build build
#        cmake --install build

    ## SECURITY

    ### FIREWALL MANAGEMENT

        # ufw - 
        #pacman -Syu ufw ufw-openrc --needed --noconfirm
        
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

    ## SCIENCE



    ## OTHERS

    ### COMPOSITE MANAGER

        pacman -Syu picom --needed --noconfirm

    ### DISPLAY MANAGER

        pacman -Syu lightdm lightdm-openrc light-locker lightdm-slick-greeter \
            --needed --noconfirm

        # lightdm
        # lightdm-openrc
        # lightdm-gtk-greeter
        # light-locker

        # Enable lightdmto start at boot
        rc-update add lightdm

        # Create directory for lightdm config files
        create_directory /etc/lightdm

        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/lightdm/lightdm.conf \
            -o /etc/lightdm/lightdm.conf
        curl $downloadUrl/dotfiles/lightdm/slick-greeter.conf \
            -o /etc/lightdm/slick-greeter.conf
        curl $downloadUrl/dotfiles/lightdm/users.conf \
            -o /etc/lightdm/users.conf

        curl $downloadUrl/dotfiles/xorg/.xprofile \
            -o $homedir/.xprofile
        chmod +x $homedir/.xprofile

    ### DISPLAY SERVER

        pacman -Syu xorg xorg-server xorg-xinit --needed --noconfirm

        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/xorg/.xinitrc \
            -o $homedir/.xinitrc
        chmod +x $homedir/.xinitrc
        curl $downloadUrl/dotfiles/xorg/xorg.conf \
            -o /etc/X11/xorg.conf

    ### PYWAL

        pacman -Syu procps imagemagick --needed --noconfirm
        runuser -l "$username" -c "pip3 install --user pywal"

        wal -i $homedir/.local/share/backgrounds/mushroom_town.png

    ### WALLPAPER SETTER

        pacman -Syu nitrogen --needed --noconfirm

        # Create directory for nitrogen config.
        create_directory $homedir/.config/nitrogen

        # Download wallpaper
        curl $downloadUrl/dotfiles/backgrounds/mushroom_town.png \
            -o $homedir/.local/share/backgrounds/mushroom_town.png
        
        # Set wallpaper for lightdm with slickgreeter-pywal
        git clone https://github.com/Paul-Houser/slickgreeter-pywal \
            $homedir/git/cloned/slickgreeter-pywal
        cd $homedir/git/cloned/slickgreeter-pywal
        chmod +x install.sh
        ./install.sh
        reTheme $(cat $HOME/.cache/wal/wal)

    ### WINDOW MANAGER

        pacman -Syu qtile --needed --noconfirm

        # Fix for qtile. It seems there are issues with building cairocffi
        # through pip and normal packages.
        runuser -l "$username" -c "pip3 install --user --no-cache --upgrade \
            --no-build-isolation cairocffi"

        create_directory $homedir/.config/qtile
        # Get config files repository and store them in corresponding directory
        curl $downloadUrl/dotfiles/qtile/config.py \
            -o $homedir/.config/qtile/config.py

    ### WINDOW SWITCHER

        pacman -Syu rofi --needed --noconfirm

    ### ZSA KEYBOARD FLASHER

        # I am using an ErgoDox EZ and this software is used to flash
        # layouts on the device.
        pacman -Syu zsa-wally --needed --noconfirm

    ## GRAPHIC DRIVERS

        # Install drivers depending on detected gpu
        if [ "$gpu" == 'AMD' ]; then
            graphicsDrivers='xf86-video-amdgpu mesa lib32-mesa vulkan-radeon'
        elif [ "$gpu" == 'INTEL' ]; then
            graphicsDrivers='xf86-video-intel mesa lib32-mesa vulkan-intel'
        elif [ "$gpu" == 'NVIDIA' ]; then
            graphicsDrivers='xf86-video-nouveau mesa lib32-mesa nvidia-utils'
        elif [ "$gpu" == 'VMware' ]; then
            graphicsDrivers='xf86-video-vmware xf86-input-vmmouse mesa lib32-mesa'
        fi

        pacman -Syu $graphicsDrivers --needed --noconfirm
    
fi

# Set all permissions and ownership in home directory correctly.
chown -R "$username":"$username" /home/"$username"

##########  END INSTALLATION TYPE SPEFIFIC INSTALLATION AND CONFIGURATION

# Finish up and remove (temporary) files

rm -rf /chrootInstall.sh /tempfiles

exit
