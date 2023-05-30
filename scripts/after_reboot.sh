#! /bin/bash

    username="$(env | grep SUDO_USER | awk -F "=" '{print $2}')"

    gitUrl="https://github.com/ArmoredGoat/artixinstall.git"
    baseUrlRaw="https://raw.githubusercontent.com"
    gitRepo="ArmoredGoat/artixinstall"
    gitBranch="iss008"
    downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"
    homedir="/home/$username"

main () {
    install_displaylink
    add_service displaylink
}

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

install_packages () {
    # Function to install multiple packages that do not require further attention
    # at once
    pacman -Syuq $@ --needed --noconfirm
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

install_displaylink () {
    # https://forum.artixlinux.org/index.php/topic,4371.0.html
    displaylinkPackages="dkms linux-headers"
    install_packages $displaylinkPackages
    install_evdi

    create_directory $homedir/.local/share/displaylink
    runuser -l "$username" -c "7z e $homedir/git/artixinstall/drivers/displaylink_5_7.zip \
        -o$homedir/.local/share/displaylink && \
        chmod ug+x $homedir/.local/share/displaylink/displaylink-driver-5.7.0-61.129.run"
    
    export SYSTEMINITDAEMON=systemd

    $homedir/.local/share/displaylink/displaylink-driver-5.7.0-61.129.run

    echo 'modules="evdi"' >> /etc/conf.d/modules

    cp $homedir/git/artixinstall/drivers/displaylink \
        /etc/init.d/displaylink
    chmod ugo+x /etc/init.d/displaylink

    sed -i 's/systemctl start displaylink-driver/rc-service displaylink start/g' \
        /opt/displaylink/udev.sh
    sed -i 's/systemctl stop displaylink-driver/rc-service displaylink stop/g' \
        /opt/displaylink/udev.sh

    sed -i 's/\*systemd\*/\*elogin\*/g' \
        /opt/displaylink/suspend.sh
    ln -sf /opt/displaylink/suspend.sh \
        /lib64/elogind/system-sleep/displaylink.sh

    export SYSTEMINITDAEMON=''
}

install_evdi () {
    runuser -l "$username" -c "git clone https://aur.archlinux.org/evdi.git \
    $homedir/git/cloned/evdi && \
    cd $homedir/git/cloned/evdi && \
    makepkg -si --noconfirm"
}

main