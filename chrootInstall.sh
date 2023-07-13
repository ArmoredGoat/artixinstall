#! /bin/bash

# This 'main' function is used to summarize and order all used functions in a
# clear way. Also, it allows to swap out functions and rearrange them witout
# much of an effort. In general, it seems to be good practice to break up
# your code into managable functions and call them in a meta main function.

main () {
    # Import variables that were stored in temporary files by install.sh
    # previously
    import_variables

    # Configure localization and clock with given timezone
    configure_localization
    configure_clock

    # Install grub and create boot entries.
    install_grub

    # Create user with given information and disable root access if wanted
    create_user
    disable_root

    # Make sure that connman service is up and running
    add_service connmand

    # Install basic packages. These are packages that are commonly necessary on
    # most machines like manuals, an editor, or tools to work with filesystems.
    install_base_packages

    # If base installation was selected, everything is done at this point.
    # The script can now be exited.
    if [[ $installationType == 'base' ]]; then
        exit
    fi

    # Create local copy of repository to have everything available.
    clone_repository
    copy_user_files

    # Install packages
    install_essential_packages
    install_internet_packages
    install_mulitmedia_packages
    install_documents_packages
    install_utiliy_packages
    install_gaming_packages
    install_science_packages
    install_security_packages
    install_others_packages

    cp $repoDirectory/scripts/after_reboot.sh $homedir/after_reboot.sh
    chmod +x $homedir/after_reboot.sh

    # Set ownership for home folder and all created files during installation
    # process to user. 
    set_ownership "$username" $homedir

    # Remove temporary files and no longer needed scripts
    remove_temporary_files
}


# FUNCTION SECTION

# Below, you will find all functions used above. They are split into the 
# following sections: meta (summaries of multiple installation functions), 
# general, configuration, installation. The functions are listed alphabetically.
# In general, the function's names are descriptive like 'install_stuff',
# 'configure_stuff', and so on. It should be possible to guess what each
# function does.

# META FUNCTIONS

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

install_documents_packages () {
    install_neovim
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
    install_yay
    configure_xdg
}

install_gaming_packages () {
    ### GAME DISTRIBUTION PLATFORM
        # steam
    gamingPackages="steam"

    install_packages $gamingPackages

    #install_minecraft
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
        wireguard-openrc firefox"

    install_packages $internetPackages

    add_service wireguard
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

    mulitmediaPackages="cmus beets imv flameshot mpv cameractrls"

    install_packages $mulitmediaPackages
    #install_aur_packages losslesscut-bin
    
    install_pipewire
    
    install_cava
}

install_others_packages () {
    # Graphical environment
    install_graphics_drivers
    install_xorg

    # Wallpaper setter
    install_nitrogen

    # Window compositor
    install_picom

    # Login manager
    install_ly

    # Window manager
    install_qtile

    # Quick and dirty test fix.
    install -Dm 755 "$repoDirectory/dotfiles/xorg/.xinitrc" -t "$homedir"

    # Window switcher, run dialog, etc.
    install_rofi

    # Notification daemon
    #install_dunst

    # Software to flash my keyboard
    install_wally
}

install_science_packages () {
    echo "Nothing here yet."
}

install_security_packages () {
    install_ufw
}

install_utiliy_packages () {
    ### ARCHIVE MANAGER
        # p7zip
    ### AUR HELPER

    # See section ESSENTIALS above.

    ### BACKUP

    # See SYNCHRONIZATION below. 

    ### BLUETOOTH MANAGEMENT
        # bluez
        # bluez-openrc
        # bluez-utils

    ### CLOCK SYNCHRONIZATION
        # connman's native ntp service is used.
    
    ### FILE MANAGER
        # ranger - 

    ### JOB SCHEDULER
        # cronie
        # local
    ### MANUALS
        # man-db
        # man-pages
        # texinfo
    ### PAGER
        # less
    ### SECURE SHELL
        # openssh
    ### SYNCHRONIZATION
        # rsync
        # rsync-openrc
    ### SYSLOGS
        # syslog-ng
        # syslog-ng-openrc
    ### SYSTEM INFORMARTION VIEWER
        #
    ### TASK MANAGER
        # bottom
    ### VERSION CONTROL SYSTEM
        # See section ESSENTIALS above.

    utilityPackages="p7zip bluez bluez-openrc bluez-utils ranger cronie \
        cronie-openrc man-db man-pages texinfo less openssh openssh-openrc \
        rsync rsync-openrc syslog-ng syslog-ng-openrc bottom"
    install_packages $utilityPackages

    # Add cronie and local services (job scheduler) to default run level
    add_service cronie
    add_service local

    # Add openssh service to enable ssh connections to machine
    add_service sshd

    # Add syslog-ng service to default runlevel to enable system logging
    add_service syslog-ng

    configure_shell
    configure_grub
    install_kitty
    install_virt_manager

    install_trash_cli
}

# GENERAL FUNCTIONS

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
    # Make sure that git is installed.
    install_packages git

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

copy_user_files () {
    # Create directories in /usr/share (systemwide) and .local/share (user-only)
    # to store backgrounds, fonts, icons, themes, ...
    create_directory $homedir/.local/share/{backgrounds,fonts/ttf,themes}
    create_directory /usr/share/backgrounds

    # Create directories for user programs and libraries
    create_directory $homedir/.local/{bin,lib}

    # Ensure ~/.local/bin is on PATH
    export PATH="$PATH:$homedir/.local/bin"

    # Copy files to corresponding directories
    # Copy fonts
    cp -r $repoDirectory/dotfiles/fonts/ttf/* \
        $homedir/.local/share/fonts/ttf
    # Copy desktop background image
    cp $repoDirectory/dotfiles/backgrounds/hollow_knight_lantern.png \
        $homedir/.local/share/backgrounds/hollow_knight_lantern.png
    # Copy login manager background image (must be in a directory
    # which can be accessed by login manager)
    cp $repoDirectory/dotfiles/backgrounds/hollow_knight_view.jpg \
        /usr/share/backgrounds/hollow_knight_view.jpg

    # Ensure permissions are set correctly for .local. Installation processes
    # for e.g. pipx require permissions for user as it is run with 'runuser'
    # command.
    set_ownership "$username" "$homedir/.local"
}

create_directory () {
	# Check if directories exists. If not, create them.
	if [[ -d $@ ]]; then
        printf "Directory '$@': already existent.\n"
    else
        mkdir -p $@
        printf "Directory '$@': created.\n"
    fi

	# This script is run with privileged rights. Therefore, anything created
	# with it will be owned by root. To make sure that the permissions are set
	# correclty, the function checks if the directory lies in the home folder.
	# If so, it grants ownership to the user.
	if [[ "$@" == $homedir/* ]]; then
		# General permissions settings. If necessary, e.g. ssh keys, the
        # permissions will be set accordingly
        chmod 755 "$@"
		chown -R "$username":"$username" "$@"
	fi

    permissions=$(ls -la "$@" | sed -n '2 p' | awk '{print $1" "$3":"$4}')
    printf "Directory '$@': permissions $permissions set.\n"
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

    homedir=/home/"$username"
    repoDirectory="$homedir/git/artixinstall"
    downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"
}

install_aur_packages () {
    runuser -l "$username" -c "yay -Syuq $1 --needed --noconfirm"
}

install_packages () {
    # Function to install multiple packages that do not require further attention
    # at once
    pacman -Syuq $@ --needed --noconfirm
}

install_pip_package () {
    runuser -l "$username" -c "pipx install $1"
}

remove_temporary_files () {
    rm -rf /chrootInstall.sh /tempfiles
}

set_ownership () {
    # Set ownership recursivly for given directory.
    chown -R "$1":"$1" $2
}

update_grub_config () {
    # Create grub configuration file in boot directory, if not existent.
    # If it is already there, update it.
    grub-mkconfig -o /boot/grub/grub.cfg    
}

# CONFIGURATION FUNCTIONS

configure_clock () {
    # TODO Explain
    hwclock --systohc --utc
}

configure_grub () {
    # Find and replace 'menu' with 'hidden' to disable grub delay to speed up 
    # boot process. If grub menu is needed, press ESC while booting
    sed -i 's/GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/g' \
        /etc/default/grub
    # Update grub config to make changes persistent
    update_grub_config
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

configure_shell () {
    # B A S H

    # Copy bash config files into user's home directory
    cp $repoDirectory/dotfiles/bash/{.bashrc,.bash_aliases,.bash_profile} \
        $homedir/
    
    # Copy bash config files into root's home directory
    cp $repoDirectory/dotfiles/bash/.bashrc_root \
        /root/.bashrc
    cp $repoDirectory/dotfiles/bash/.bash_profile \
        /root/.bash_profile

    # Make bash files executable. Necessary for some applications.
    chmod +x $homedir/{.bashrc,.bash_profile}

    install_packages bash-completion

    # Source .bashrc to make configuration active.
    source $homedir/.bashrc
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

# INSTALLATION FUNCTIONS

install_cava () {
    # Make sure requirements are installed
    cavaPackages="base-devel fftw ncurses alsa-lib iniparser pipewire-pulse autoconf-archive"

    install_packages $cavaPackages

    # Install cava from AUR
    install_aur_packages cava

    # Create config directory for cava
    create_directory $homedir/.config/cava

    # Copy configuration file into directory
    cp $repoDirectory/dotfiles/cava/config \
        $homedir/.config/cava/config
}

install_yay () {
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

install_git () {
    install_packages git

    # Create directory for git repositories
    create_directory $homedir/git/{own,cloned}
}

install_graphics_drivers () {
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
    # Check boot type and install correct version
    if [ "$boot" == 'uefi' ]; then
        # grub - 
        # efibootmgr - 
        # os-prober - Detection of other installed operating systems
        packagesGrub="grub efibootmgr os-prober"

        install_packages $packagesGrub

        grub-install --target=x86_64-efi --efi-directory=/boot/efi \
            --bootloader-id=grub --recheck
        # grub-install --target=x86_64-efi --efi-directory=/boot/EFI \
        #    --bootloader-id=GRUB-rwinkhart --recheck
        # TODO Learn about bootloader-id
    elif [ "$boot" == 'bios' ]; then
        packagesGrub="grub os-prober"

        install_packages $packagesGrub

        grub-install --target=i386-pc --recheck $baseDisk
    fi

    update_grub_config
}

install_kitty () {
    ### TERMINAL EMULATOR

    install_packages kitty

    # Create directories for kitty's general configs and themes
    create_directory $homedir/.config/{kitty,kitty/themes}

    # Copy nord theme for kitty by connorholyday into themes directory
    # https://github.com/connorholyday/nord-kitty/tree/master
    cp $repoDirectory/dotfiles/themes/nord_kitty.conf \
        $homedir/.config/kitty/themes/nord.conf
    ## General configuration
    # Get config files repository and store them in corresponding directory
    cp $repoDirectory/dotfiles/kitty/kitty.conf \
        $homedir/.config/kitty/kitty.conf
}

install_ly () {
    # Ly is a lightweight TUI (ncurses-like) display manager for Linux and BSD.
    # https://github.com/fairyglade/ly

    # Clone repository into git directory and compile it with 'make'.
    git clone --recurse-submodules https://github.com/fairyglade/ly \
        $homedir/git/ly
    cd $homedir/git/ly
    make
    
    # Install Ly and the OpenRC service
    cd $homedir/git/ly
    make install installopenrc
    
    # Enable service to start on boot.
    add_service ly

    # By default Ly uses tty2 which already has a login/getty (basic login 
    # prompt) running. To prevent this prompt to spawn on top of Ly it has
    # to be disabled.
    rc-update del agetty.tty2 default
}

install_microcode () {
    if [[ $cpu == 'AMD' ]] || [[ $cpu == 'AuthenticAMD' ]]; then
        microcodePackage='amd-ucode'
    elif [[ $cpu == 'Intel' ]] || [[ $cpu == 'GenuineIntel' ]]; then
        microcodePackage='intel-ucode'
    fi

    install_packages $microcodePackage
}

install_minecraft () {
    ### MINECRAFT LAUNCHER

    # Build dependencies
        # qt6
        # ninja
        # cmake
        # extra-cmake-modules
        # zlib
    minecraftPackages="qt6 ninja cmake extra-cmake-modules zlib"
    install_packages $minecraftPackages

    # Clone repository and move into it
    git clone --recursive https://github.com/Diegiwg/PrismLauncher-Cracked.git \
        $homedir/git/cloned/prismlauncher
    cd $homedir/git/cloned/prismlauncher

    # Create build
    cmake -S . -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="/usr" \
        -DENABLE_LTO=ON \
        -DLauncher_QT_VERSION_MAJOR="6"

    # Build and install previously prepared build
    cmake --build build
    cmake --install build
}

install_neovim () {
    # Build prerequisites
    neovimPrerequisites="base-devel cmake unzip ninja curl"
    install_packages $neovimPrerequisites

    # Build Neovim (stable) from source
#    runuser -l "$username" -c "git clone https://github.com/neovim/neovim \
#        $homedir/git/cloned/neovim && \
#        cd $homedir/git/cloned/neovim && \
#        make CMAKE_BUILD_TYPE=RelWithDebInfo && \
#        git checkout stable && \
#        sudo make install"

    install_packages neovim

    # Create directory for config files and plugins
    create_directory $homedir/.config/nvim/lua/custom/plugins

    # Copy configuration into corresponding directory
    cp -r $repoDirectory/dotfiles/nvim/* \
        $homedir/.config/nvim/
}

install_nitrogen () {
    ### WALLPAPER SETTER

    pacman -Syu nitrogen --needed --noconfirm

    # Create directory for nitrogen config.
    create_directory $homedir/.config/nitrogen

    # Copy nitrogen config into directory
    cp $repoDirectory/dotfiles/nitrogen/* \
        $homedir/.config/nitrogen/
}

install_picom () {
    # C O M P O S I T E  M A N A G E R

    install_packages picom

    # Create directories for nitrogen config and log files
    create_directory $homedir/{.config/picom,.local/share/picom}

    # Copy configuration file for picom into corresponding directory.
    cp $repoDirectory/dotfiles/picom/picom.conf \
        $homedir/.config/picom/picom.conf
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

install_pipx () {
        # python-pipx - 
    # https://pypa.github.io/pipx/
    # pipx is like pip a general-purpose package installer for Python and uses
    # the same package index, PyPI. As it is specifacally made for application
    # installation, it adds isolation while maintaining availability and 
    # connectiity between apps and shell. By using virtual environments, pipx
    # addresses the problem that packages provided by apt and pip are mixed up.
    # Mixing two package managers is a bad idea. Therefor, your distro protects
    # you from doing that.
    # pipx runs with regular user permissions and installs packages in 
    # ~/.local/bin, so make sure that it is on PATH by either add an export to
    # your .bashrc or by calling 'pipx ensurepath'.
    
    # Ensure pipx is on PATH before go further. On the finished system the 
    # PATH is set in ~/.bashrc
    runuser -l "$username" -c "pip install pipx --break-system-packages && \
        export PATH=$PATH:$HOME/.local/bin"

}

install_python () {
    ### PYTHON
        # python -
    pythonPackages="python python-pip python-setuptools python-virtualenv"
    install_packages $pythonPackages

    install_pipx
}

install_qtile () {
    # W I N D O W   M A N A G E R
    qtile_packages="dbus gdk-pixbuf2 git glibc graphviz gtk3 imagemagick \
        libnotify libpulse lm_sensors mypy pango python-bowler \
        python-cairocffi python-cffi python-dbus-next python-gobject \
        python-iwlib python-psutil python-pytest python-setproctitle \
        python-setuptools python-setuptools-scm python-xcffib python-xdg \
        python-xvfbwrapper xorg-server-xephyr xorg-xrandr"
    install_packages $qtile_packages

    runuser -l "$username" -c "export PATH=$PATH:$HOME/.local/bin && \
        pipx install git+https://github.com/qtile/qtile@master"
    #install_pip_package "git+https://github.com/qtile/qtile@master"

    # Create a virtual environment for qtile and enter it by sourcing it
    # 'bin/activate' inside. Then install psutil with pip so qtile has access
    # to its functions. Afterwards, leave.
    runuser -l "$username" -c "virtualenv ~/.local/pipx/venvs/qtile && \
        source virtualenv ~/.local/pipx/venvs/qtile/bin/activate && \
        pip install psutil && \
        deactivate"

    create_directory $homedir/.config/qtile
    # Get config files repository and store them in corresponding directory
    cp -r $repoDirectory/dotfiles/qtile/* \
        $homedir/.config/qtile/
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

    rofiPackages="rofi papirus-icon-theme"

    install_packages $rofiPackages

    create_directory $homedir/.config/rofi

    cp $repoDirectory/dotfiles/rofi/config.rasi \
        $homedir/.config/rofi/config.rasi
}

install_trash_cli () {
    install_packages trash-cli

    # Create cron job to delete all files that are trashed longer than
    # 90 days on a daily basis. The '2>/dev/null' is necessary to
    # surpress 'no crontab for [username]' message.
    (crontab -l 2>/dev/null ; echo "@daily $(which trash-empty) 90") | \
        crontab -    
}

install_ufw () {
    ### FIREWALL MANAGEMENT

    # ufw - 
    install_packages "ufw ufw-openrc"
    
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
    create_directory /etc/ufw

    cp $repoDirectory/dotfiles/ufw/* \
        /etc/ufw/
}

install_virt_manager () {
    ### VIRTUALIZATION

    pacman -Rdd iptables --noconfirm
    virtualizationPackages="virt-manager qemu-desktop qemu-guest-agent-openrc \
        dnsmasq iptables-nft"

    install_packages $virtualizationPackages

    # Set UNIX domain socket ownership to libvirt and permissions to read
    # and write by uncommenting the following lines

    sed -i "/unix_sock_group = /s/^#//g" /etc/libvirt/libvirtd.conf
    sed -i "/unix_sock_rw_perms = /s/^#//g" /etc/libvirt/libvirtd.conf

    # Add user to libvirt group
    usermod -aG libvirt "$username"

    sed -i "s/user = \"libvirt-qemu\"/user = \"$username\"/" \
        /etc/libvirt/libvirtd.conf
    sed -i "s/group = \"libvirt-qemu\"/group = \"$username\"/" \
        /etc/libvirt/libvirtd.conf
}

install_wally () {
    ### ZSA KEYBOARD FLASHER

    # I am using an ErgoDox EZ and this software is used to flash
    # layouts on the device.
    pacman -Syu zsa-wally-cli --needed --noconfirm
}

install_xorg () {
    ### DISPLAY SERVER
    xorgPackages="xorg xorg-server xorg-xinit"
    install_packages $xorgPackages
}

##########  END FUNCTIONS

main # Call main function

exit # Exit chrootInstall.sh and return to the remaining part of install.sh
