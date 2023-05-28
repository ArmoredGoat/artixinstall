#! /bin/bash

gitUrl="https://github.com/ArmoredGoat/artixinstall.git"
baseUrlRaw="https://raw.githubusercontent.com"
gitRepo="ArmoredGoat/artixinstall"
gitBranch="iss008"
downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"
homedir=/home/"$username"
repoDirectory="$homedir/git/artixinstall"

# This 'main'-function is used to summarize and order all used functions in a
# clear way. Also, it allows to swap out functions and rearrange them witout
# much of an effort. In general, it seems to be good practice to break up
# your code into managable functions and call them in a meta 'main'-function.

main () {
    # Import variables that were stored in temporary files by install.sh
    # previously
    import_variables

    # Configure localization and clock with given timezone
    configure_localization
    configure_clock

    # Create user with given information and disable root access if wanted
    create_user
    disable_root

    add_service connmand

    # Install basic packages. These are packages that are commonly necessary on
    # most machines like manuals, an editor, or tools to work with filesystems.
    install_base_packages

    # If base installation was selected, everything is done at this point.
    # The script can now be exited.
    if [[ $installationType == 'base' ]]; then
        exit
    fi

    clone_repository

    ## ESSENTIALS

    install_essential_packages

    ## INTERNET

    install_internet_packages

    ## MULTIMEDIA

    install_mulitmedia_packages

    ## UTILITY

    install_trash_cli

    ## OTHERS

    install_graphics_drivers $gpu

    install_nitrogen
    install_pywal
    install_qtile
    install_rofi
    install_wally

    rm -rf /chrootInstall.sh /tempfiles
}


# FUNCTION SECTION

# Below, you will find all functions used above. They are listed alphabetically.
# In general, the function's names are descriptive like 'install_stuff',
# 'configure_stuff', and so on. It should be possible to guess what each
# function does.

add_service () {
    # Set service to given package/service
    service="$1"
    
    # If no runlevel is given, set runlevel to default. Otherwise, use given
    # runlevel.
    if [[ ! "$2" ]]; then
        runlevel="default"
    else
        runlevel="$2"
    fi

    # Add service to a runlevel to run it automatically if runlevel is met.
    # TODO Explain runlevels
    rc-update add $service $runlevel

    # Start service now. Most of the time, the service is already running
    # after installation but it never hurts to make sure.
    rc-service $service start
}

clone_repository () {
    # Check if git is already installed on the system. If not, install it.
    checkGit=$(pacman -Q git)

    if [[ ! $checkGit ]]; then
        install_packages git
    fi

    # Clone git repository to /home/git
    git clone $gitUrl $homedir/git/artixinstall
    # Move into repo directory
    cd $homedir/git/artixinstall
    # Get current branch
    currentBranch=$(git status | grep 'On branch' | awk '{print $3}')

    # Compare current branch with working branch. If it does not match,
    # switch to working branch.
    if [[ ! "$currentBranch" == "$gitBranch" ]]; then
        git checkout $gitBranch
    fi
}

configure_clock () {
    # TODO Explain
    hwclock --systohc --utc
}

configure_localization () {
    # By uncommenting localizations/languages in /etc/locale.gen, the system
    # create the necessary files for using it the next time 'locale-gen' is run.
    sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen

    # Set desired locale system-wide by setting and exporting the LANG
    # environment variable.
    echo 'export LANG="en_US.UTF-8"' > /etc/locale.conf
    
    # Set collation rules (rules for sorting and regular expresions) 
    # system-wide by setting and exporting the LC_COLLATE environment variable.
    # The value 'C' tell the system to list dotfiles first, followed by 
    # uppercase and lowercase filenames.
    echo 'export LC_COLLATE="C"' >> /etc/locale.conf
    
    # Set time zone by creating a symbolic link to the according file in
    # time zone directory.
    ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    
    # Generate localization
    locale-gen
}

configure_pacman () {
    ### PACMAN

    # Copy configuration file into according directory
    cp $repoDirectory/dotfiles/pacman/pacman.conf \
        /etc/pacman.conf

    create_directory /etc/pacman.d

    # Get recent mirror lists
    archSvnRepo="archlinux/svntogit-packages/packages"
    curl $baseUrlRaw/$archSvnRepo/pacman-mirrorlist/trunk/mirrorlist \
        -o /etc/pacman.d/mirrorlist-arch

    # Uncomment every mirror temporarily to download reflector
    sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch

    # Install and enable support of Arch repositories
    install_packages artix-archlinux-support
    # Retrieve keys
    pacman-key --populate archlinux

    # Install additional packages
    install_reflector

    install_packages pacman-contrib

    #TODO add paccache to cron    
}

configure_xdg () {
    ### XDG
    install_packages xdg-user-dirs

    create_directory /etc/xdg

    # Get config files repository and store them in corresponding directory
    cp $repoDirectory/dotfiles/xdg/user-dirs.defaults \
        /etc/xdg/user-dirs.defaults

    create_directory $homedir/{downloads,documents/{music,public,desktop,templates,pictures,videos}}
}

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

create_user () {
    # Create user with a personal directory in /home
    useradd -m "$username"

    # Set password
    echo "$userPassword
    $userPassword
    " | passwd "$username"

    # Add user to the following groups
    usermod -aG wheel,audio,video,storage "$username"

    # Uncomment the following line in /etc/sudoers grants users in wheel
    # group sudo privileges. Therefore, there is no need for a root user
    sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//g' /etc/sudoers

    # By appending this line to /etc/sudoers, it disables the password prompt
    # for this user when using 'sudo'.
    # TODO Instead of disabling the prompt, increase time before user has to
    # enter the password again to 30 - 60 minutes,
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    # Set home directory permissions
    chmod 755 /home/"$username"
    create_directory $homedir/{.config,.local/share}
}

disable_root () {
    # As your personal user will be granted privileged rights, a root user is
    # not necessary. It is also the most targeted user of brute force attacks
    # since it is existent on all devices. Without a root user to login to,
    # users have to enter 'sudo' priot to their commands. It also is stopping 
    # users from entering a full root shell which makes it easier to do 
    # something wrong. Therefore, it is recommended to disable the root account
    # by removing the password and locking it. Afterwards, no login or ssh
    # connection into root is possible. You can, of course, change that later
    # on by using 'sudo' and giving root a viable password

    # Check if root password shall be set and set it. If not, lock it.
    if [ "$setRootPassword" = true ]; then
        echo "$rootpassword
        $rootpassword
        " | passwd
    else
        # Setting the password of a user to '!' looks the account, refer to
        # manual page 'shadow(5)'. It has the same effect as 'passwd --lock'
        usermod -p '!' root
    fi
}

import_variables () {
    # If a directory is specified, use it. Otherwise, use '/tempfiles'.
    if [[ $1 ]]; then
        directory="$1"
    else
        directory="/tempfiles"
    fi

    # Loop through all files in directoy
    for file in "$directory"/*; do
        # Check if it is a regular file. It yes, do the stuff below.
        if [[ -f "$file" ]]; then
            fileName=$(basename "$file") # Get name of file without path
            varName="${fileName%.*}" # Remove file extenstion from file name
            varValue=$(cat "$file") # Read file contents

            # Declare a global (-g) read-only (-r) variable and assign value.
            # Without -g, the variable would not be accessible outside the
            # function's scope.
            declare -rg "$varName"="$varValue"

            # For traceability, the function will return the variables' name
            # after declaring it. If something is wrong, you can check the
            # logs to see if there are any errors regarding the variables.
            echo "Declared variable: $varName"
        fi
    done 
}

install_aur_helper () {
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
}

install_aur_package () {
    runuser -l "$username" -c "yay -Syuq $@ \
        --needed --noconfirm"
}

install_base_packages () {
    # Manuals
        # man-db    -
        # man-pages -
        # texinfo   -

    # General administration
        # sudo

    # Filesystem adiminstration
        # e2fsprogs -
        # dosfstools    -

    # Editor
        # nano  -

    baseInstallationPackages="man-db man-pages texinfo nano sudo e2fsprogs dosfstools" 

    install_packages $baseInstallationPackages
}

install_essential_packages () {
    ### FIRMWARE
        # sof-firmware -
    ### JAVA
        # jdk17-openjdk - 
    essentialPackages="sof-firmware jdk17-openjdk"

    install_packages $essentialPackages
    install_microcode
    install_python
    install_git
    configure_pacman
    install_aur_helper
    configure_xdg
}

install_git () {
    install_packages git

    # Create directory for git repositories
    create_directory $homedir/git/{own,cloned}
}

install_graphics_drivers () {
    # Set gpu variable to given value
    gpu="$1"
    # Check which graphics card manufacturer was detected and select packages
    # accordingly.
    if [ "$gpu" == 'AMD' ]; then
        graphicsDrivers='xf86-video-amdgpu mesa lib32-mesa vulkan-radeon'
    elif [ "$gpu" == 'INTEL' ]; then
        graphicsDrivers='xf86-video-intel mesa lib32-mesa vulkan-intel'
    elif [ "$gpu" == 'NVIDIA' ]; then
        graphicsDrivers='xf86-video-nouveau mesa lib32-mesa nvidia-utils'
    elif [ "$gpu" == 'VMware' ]; then
        graphicsDrivers='xf86-video-vmware xf86-input-vmmouse mesa lib32-mesa'
    fi

    install_packages $graphicsDrivers
}

install_grub () {
    # grub - 
    # efibootmgr - 
    # os-prober - Detection of other installed operating systems
    packagesGrub="grub efibootmgr os-prober"

    install_packages $packagesGrub

    # Check boot type and install correct version
    if [ "$boot" == 'uefi' ]; then
        grub-install --target=x86_64-efi --efi-directory=/boot/efi \
            --bootloader-id=grub --recheck
        # grub-install --target=x86_64-efi --efi-directory=/boot/EFI \
        #    --bootloader-id=GRUB-rwinkhart --recheck
        # TODO Learn about bootloader-id
    elif [ "$boot" == 'bios' ]; then
        grub-install --target=i386-pc --recheck $baseDisk
    fi

    update_grub_config
}

install_internet_packages () {
    ### CLOUD SYNCHRONIZATION
        # nextcloud-client - 
    ### EMAIL CLIENT
        # neomutt - 
    ### INSTANT MESSAGING
    #### MULTI-PROTOCOL CLIENT
        # weechat -
    #### OTHER INSTANT MESSAGING CLIENTS
        # discord -
    ### NETWORK MANAGER
        # See install.sh. connman and wpa_supplicant are being used.
    ### VPN CLIENT
        # wireguard-tools - 
        # wireguard-openrc -
    ### WEB BROWSER
        # firefox-esr - 

    internetPackages="nextcloud-client neomutt weechat discord wireguard-tools \
        wireguard-openrc firefox-esr"

    install_packages $internetPackages

    add_service wireguard
}

install_microcode () {
    if [[ $cpu == 'AuthenticAMD' ]]; then
        microcodePackage='amd-ucode'
    elif [[ $cpu == 'Intel' ]] || [[ $cpu == 'GenuineIntel' ]]; then
        microcodePackage='intel-ucode'
    fi

    install_packages $microcodePackage
}

install_mulitmedia_packages () {
    ### AUDIO PLAYER
        # cmus - 
    ### AUDIO TAG EDITOR
        # beets - 
    ### AUDIO VISUALIZER
        # cli-visualizer-git - 
    ### IMAGE VIEWER
        # imv -
    ### SCREENSHOTS
        # flameshot - 
    ### VIDEO PLAYER
        # mpv -
    ### VIDEO EDITOR
        # losslesscut
    ### WEBCAM
        # cameractrls - 
    
    ### OPTICAL DISK RIPPING

    # Installing makemkv-cli requires to accept the EULA, which pops up
    # before finishing the process. The pager 'less' is used to display
    # the text. To automatically leave less the command line option
    # LESS='+q' is given along. Then it behaves as 'q' was entered manually.
    # "yes 'yes'" outputs a constant stream of 'yes' strings 
    # followed by a new line. This way as soon as the script leaves the
    # pager, it accepts the EULA.
    #runuser -l "$username" -c "yes 'yes' | LESS='+q' yay -Syu makemkv-cli \
    #    --needed --noconfirm"

    mulitmediaPackages="cmus beets imv flameshot mpv cameracrtls"
    mulitmediaPackagesAur="losslesscut-bin cli-visualizer-git"

    install_packages $mulitmediaPackages
    install_aur_package $mulitmediaPackagesAur

    install_pipewire
}


install_nitrogen () {
    ### WALLPAPER SETTER

    pacman -Syu nitrogen --needed --noconfirm

    # Create directory for nitrogen config.
    create_directory $homedir/.config/nitrogen

    # Download wallpaper
    curl $downloadUrl/dotfiles/backgrounds/mushroom_town.png \
        -o $homedir/.local/share/backgrounds/mushroom_town.png
}

# Function to install multiple packages that do not require further attention
# at once
install_packages () {
    pacman -Syuq $@ --needed --noconfirm
}


install_pipewire () {
    # Remove jack2 as it creates conflicts with pipewire-jack
    pacman -Rdd jack2 --noconfirm
    # Install pipewire and related packages
    pacman -Syu pipewire lib32-pipewire pipewire-audio pipewire-alsa \
        pipewire-pulse pipewire-jack pipewire-docs wireplumber pavucontrol \
        --needed --noconfirm
    # Create configuration directory
    create_directory $homedir/.config/pipewire
    # Copy configuration file into according directory
    cp $repoDirectory/dotfiles/pipewire/pipewire.conf \
        $homedir/.config/pipewire/pipewire.conf
    # Copy start-up script into configuration directory
    cp $repoDirectory/dotfiles/pipewire/.pipewire-start.sh \
        $homedir/.config/pipewire/.pipewire-start.sh
    # Make start-up script executable
    chmod +x $homedir/.config/pipewire/.pipewire-start.sh
}

install_python () {
    ### PYTHON
        # python -
        # python-pip - 
    pythonPackages="python python-pip"

    # Make sure this directory exists and the user has permissions
    # This directory has to be accessed when installing python modules
    create_directory /home/"$homedir"/.local/lib

    # Install python module 'setuptools' for user with pip
    runuser -l "$username" -c "pip3 install --user setuptools"
}

install_pywal () {
        ### PYWAL

        pacman -Syu procps imagemagick --needed --noconfirm
        runuser -l "$username" -c "pip3 install --user pywal"
}

install_qtile () {
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
}

install_reflector () {
    ### REFLECTOR

    # reflector -
    install_packages reflector

    # Run reflector to select the best five servers for my country
    reflector --save /etc/pacman.d/mirrorlist-arch --country Germany \
        --protocol https --latest 5

    # Copy config file and store them in corresponding 
    # directory. Add file reflector.start to local.d directory to run 
    # reflector at start without systemd
    cp $repoDirectory/dotfiles/local.d/reflector.start \
        /etc/local.d/reflector.start
    # Make reflector.start executable
    chmod +x /etc/local.d/reflector.start
}

install_rofi () {
    ### WINDOW SWITCHER

    pacman -Syu rofi --needed --noconfirm
}

install_trash_cli () {
    pacman -Syu trash-cli --needed --noconfirm

    # Create cron job to delete all files that are trashed longer than
    # 90 days on a daily basis. The '2>/dev/null' is necessary to
    # surpress 'no crontab for [username]' message.
    (crontab -l 2>/dev/null ; echo "@daily $(which trash-empty) 90") | \
        crontab -    
}

install_wally () {
    ### ZSA KEYBOARD FLASHER

    # I am using an ErgoDox EZ and this software is used to flash
    # layouts on the device.
    pacman -Syu zsa-wally --needed --noconfirm
}

update_grub_config () {
    # Create grub configuration file in boot directory, if not existent.
    # If it is already there, update it.
    grub-mkconfig -o /boot/grub/grub.cfg    
}

##########  END FUNCTIONS

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
    update_grub_config

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
    create_directory $homedir/.fonts/ttf

### VERSION CONTROL SYSTEM

    # See section ESSENTIALS above.

### VIRTUALIZATION

    pacman -Rdd iptables --noconfirm
    pacman -Syu virt-manager qemu-desktop qemu-guest-agent-openrc \
        dnsmasq iptables-nft --needed --noconfirm

    # Set UNIX domain socket ownership to libvirt and permissions to read
    # and write by uncommenting the following lines

    sed -i "/unix_sock_group = /s/^#//g" /etc/libvirt/libvirtd.conf
    sed -i "/unix_sock_rw_perms = /s/^#//g" /etc/libvirt/libvirtd.conf

    usermod -aG libvirt "$username"

    sed -i "s/user = \"libvirt-qemu\"/user = \"$username\"/" \
        /etc/libvirt/libvirtd.conf
    sed -i "s/group = \"libvirt-qemu\"/group = \"$username\"/" \
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

    # Set wallpaper for lightdm with slickgreeter-pywal
    git clone https://github.com/Paul-Houser/slickgreeter-pywal \
        $homedir/git/cloned/slickgreeter-pywal
    cd $homedir/git/cloned/slickgreeter-pywal
    chmod +x install.sh
    ./install.sh
    reTheme $(cat $HOME/.cache/wal/wal)

### DISPLAY SERVER

    pacman -Syu xorg xorg-server xorg-xinit --needed --noconfirm

    # Get config files repository and store them in corresponding directory
    curl $downloadUrl/dotfiles/xorg/.xinitrc \
        -o $homedir/.xinitrc
    chmod +x $homedir/.xinitrc
    curl $downloadUrl/dotfiles/xorg/xorg.conf \
        -o /etc/X11/xorg.conf

    wal -i $homedir/.local/share/backgrounds/mushroom_town.png

# Set all permissions and ownership in home directory correctly.
chown -R "$username":"$username" /home/"$username"

# Call main function

main

exit