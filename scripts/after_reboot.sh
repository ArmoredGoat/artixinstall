#! /bin/bash

    gitUrl="https://github.com/ArmoredGoat/artixinstall.git"
    baseUrlRaw="https://raw.githubusercontent.com"
    gitRepo="ArmoredGoat/artixinstall"
    gitBranch="iss008"
    downloadUrl="$baseUrlRaw/$gitRepo/$gitBranch"

main () {
    install_displaylink
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

    create_directory /home/julius/.local/share/displaylink
    cd /home/julius/.local/share/displaylink
    7z e /home/julius/git/artixinstall/drivers/displaylink_5_7.zip \
        -o/home/julius/.local/share/displaylink
    
    chmod ug+x displaylink-driver-5.7.0-61.129.run

    export SYSTEMINITDAEMON=systemd

    ./displaylink-driver-5.7.0-61.129.run

    echo 'modules="evdi"' >> /etc/conf.d/modules

    cp /home/julius/git/artixinstall/drivers/displaylink \
        /etc/init.d/displaylink
    chmod ugo+x /etc/init.d/displaylink

    sed -i 's/systemctl start displaylink-driver/rc-service displaylink start/g' \
        /opt/displaylink/udev.sh
    sed -i 's/systemctl stop displaylink-driver/rc-service displaylink stop/g' \
        /opt/displaylink/udev.sh

    sed -i 's/if [[ $DIR == *systemd* ]]/if [[ $DIR == *elogin* ]]/g' \
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