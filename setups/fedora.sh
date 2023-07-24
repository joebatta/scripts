#!/bin/bash
# GioBatta - Setup Fedora

# // Variables
BOLD='\e[1m'
RESET='\e[0m'
cyan='\e[96m'
green='\e[32m'
gray='\e[37m'
magenta='\e[35m'
white='\e[97m'

# TODO: GNOME_VERSION = gnome-shell --version
GNOME_VERSION=44

# // Functions
function out() {
	echo -e "${BOLD}${magenta}==> ${white}$1"
}

function log() {
	echo -e "${BOLD}${cyan}[${green}$1${cyan}]${gray} $2"
}

function dnf-run() {
	if (sudo dnf info $1 &> /dev/null); then
		sudo dnf update $1 -y
	else 
		sudo dnf install $1 -y
	fi
}

function flt-run() {
	sudo flatpak install flathub $1 -y
}

# // Script
sudo -H dbus-launch gsettings set org.gnome.login-screen disable-user-list true
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo bash -c 'cat << EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'

out "Removing unwanted apps"
sudo dnf remove firefox -y
sudo dnf remove rhythmbox -y
sudo dnf remove gnome-maps -y
sudo dnf remove gnome-shell-extension-background-logo -y
sudo dnf remove gnome-calendar -y
sudo dnf remove cheese -y

out "Installing launch-pad"
dnf-run "git"
dnf-run "gnome-shell-extension-dash-to-dock"

out "Updating settings"

gsettings set org.gnome.desktop.interface show-battery-percentage true
log "~" "show-battery-percentage = true"

gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
log "~" "natural-scroll = false"

gsettings set org.gnome.mutter dynamic-workspaces false
log "~" "dynamic-workspaces = false"

gsettings set org.gnome.desktop.wm.preferences num-workspaces 2
log "~" "num-workspaces = 2"

gsettings set org.gnome.desktop.wm.preferences audible-bell false
log "~" "audible-bell = false"

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
log "~" "dock-position = LEFT"

gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
log "~" "dash-max-icon-size = 32"

gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
log "~" "show-trash = false"

out "Installing apps"
dnf-run "code"
log "+" "Fedora: Visual Studio code"

dnf-run "kate"
log "+" "Fedora: Kate"

flt-run "io.beekeeperstudio.Studio"
log "+" "Flathub: Beekeeper Studio"

flt-run "com.spotify.Client"
log "+" "Flathub: Spotify"

out "Miscellaneous extra"
log "~" ""

# // Exit
echo -e "${RESET}"
