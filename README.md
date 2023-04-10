# ArixInstall - an interactive Artix installation script (WIP)

## About this project

### What does this script do?

This script is written to provide an automated but interactive process to install Artix Linux on any 

### Why did I write this script?

First of all, this is my first more complex bash script and GitHub project. I started this project to learn bash scripting and working with git as I plan to become a DevOps after my training as an IT specialist for system integration. Furthermore, I wanted to have an ever ongoing project which keeps getting better and more versatile the more I learn about bash scripting, linux and system administration. Therefore, I am grateful for any tips and tricks provided.

Maybe this script will inspire other users who are also new to Arch/Artix to write their own scripts or help to improve this one.

### What features and improvements do I plan to implement later on?

**Higher priority**

- Add customized installation process
    - Add customization (duh!): qtile, neovim for coding and LaTeX, mouseless workflows, ricing, ...
- Find a better way to control cursor/delete temporary output while going through the configuration process

**Lower priority**

- Add support for other init systems (only for base installation; might implement in distant future if not to complicated)
- Add possibility to select which packages will be installed for the base installation

**Permanently ongoing**

- Refactor and improve code according to my learning process
- Improve documentation and comments of code
- Improve README

## How to use the script?

1. Boot up your PC from an Artix live iso [(ArtixLinux' download page)](https://artixlinux.org/download.php) 
    - Currently, only the base version with OpenRC is supported
2. Login with the given credentials on the screen
3. Switch to root by entering `sudo su` 
4. Connect to the internet by following the instructions given on the Artix or Arch wiki
5. Run the folliwng commands to run the script and follow the instructions
```
# Download the installation script and save it as install.sh in current directory
curl https://raw.githubusercontent.com/ArmoredGoat/artixinstall/main/install.sh -o install.sh
# Make install.sh executable
chmod +x install.sh
# Execute install.sh
./install.sh
```
6. After getting through with the installation, you should have a running Artix installation. Enjoy :]


## How to contribute to this project?

Please let me know if you run into errors or problems that shouldn't be there by opening an issue or reaching out to me on ~~Social Media~~ (Will create accounts later...).

Also, at it is my first more complex scripts, **please** tell me if there are better ways to implement the features I had in mind. I don't know all the possibilities of bash that are available on the iso and there might be just the right command to substitute my clanky workarounds but I wasn't aware :)

Check [What features and improvements do I plan to implement later on?](https://github.com/ArmoredGoat/artixinstall/edit/development/README.md#what-features-and-improvements-do-i-plan-to-implement-later-on) to see what I am up to and where my prorities are. Maybe there is something you want to help with or you could give a hint for.

I am grateful for any advice that might improve this project and/or my skills in shell scripting.

## Credits

The general process and some ways of doing things come from [rwinkhart's Artix install script](https://github.com/rwinkhart/artix-install-script). I used it to get the general idea of an automated installation process, how and which information should be gathered by the script, and to finally install Artix via a script.
