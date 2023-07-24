#!/bin/bash
# GioBatta - Setup Fedora

# ---------------------------------------------------------
# NOTE: Make sure the system and store is up-to-date
# ---------------------------------------------------------

# // Variables
BOLD='\e[1m'
RESET='\e[0m'
cyan='\e[96m'
green='\e[32m'
gray='\e[37m'
magenta='\e[35m'
white='\e[97m'

JB_TOOLBOX_VERSION="1.28.1.15219"
DOWNLOAD_JB_TOOLBOX="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${JB_TOOLBOX_VERSION}.tar.gz"

# // Functions
function out() {
	echo -e "${BOLD}${magenta}==> ${white}$1"
}

function log() {
	echo -e "${BOLD}${cyan}[${green}$1${cyan}]${gray} $2"
}

function conf_write() {
	dconf write $1 $2
	log "~" "$1 = $2"
}

function dnf-install() {
	echo -e "${gray}--> Installing: ${white}$1"
	sudo dnf install $1 -y &> /dev/null
	log "+" "dnf: $1"
}

function flt-run() {
	echo -e "${gray}--> Installing: ${white}$1"
	sudo flatpak install flathub $1 -y &> /dev/null
	log "+" "flt: $1"
}

# // Script
sudo dnf upgrade --refresh

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
sudo dnf remove rhythmbox gnome-maps gnome-shell-extension-background-logo gnome-calendar cheese -y &> /dev/null
sleep 1
source ~/.bashrc

out "Installing launch-pad"
#
sudo dnf -y update git
dnf-install "gnome-shell-extension-dash-to-dock"
dnf-install "fira-code-fonts"
sleep 1
source ~/.bashrc

out "Updating settings"
#

gnome-extensions enable dash-to-dock@micxgx.gmail.com

conf_write "/org/gnome/desktop/interface/show-battery-percentage" true
conf_write "/org/gnome/desktop/peripherals/mouse/natural-scroll" false
conf_write "/org/gnome/mutter/dynamic-workspaces" false
log "+" "Applied: settings"
conf_write "/org/gnome/desktop/wm/preferences/num-workspaces" 2
conf_write "/org/gnome/desktop/wm/preferences/audible-bell" false
log "+" "Applied: preferences settings"
conf_write "/org/gnome/shell/extensions/dash-to-dock/dock-position" "'LEFT'"
conf_write "/org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size" 32
conf_write "/org/gnome/shell/extensions/dash-to-dock/show-trash" false
log "+" "Applied: dash-to-dock settings"
sleep 1

out "Installing apps"
#

dnf-install "code"
dnf-install "kate"
dnf-install "fastfetch"
dnf-install "htop"
dnf-install "podman"
sleep .75
source ~/.bashrc

flt-run "io.beekeeperstudio.Studio"
log "+" "Flathub: Beekeeper Studio"
flt-run "com.spotify.Client"
log "+" "Flathub: Spotify"
flt-run "io.podman_desktop.PodmanDesktop"
log "+" "Flathub: Podman Desktop"
sleep .75
source ~/.bashrc

wget $DOWNLOAD_JB_TOOLBOX -q
sudo tar -xvzf ./jetbrains-toolbox-${JB_TOOLBOX_VERSION}.tar.gz
sudo mv ./jetbrains-toolbox-${JB_TOOLBOX_VERSION}/jetbrains-toolbox /opt/
sudo wget https://www.iconarchive.com/download/i105820/papirus-team/papirus-apps/jetbrains-toolbox.512.png -q -O /opt/jetbrains-toolbox.png
sudo bash -c 'cat << EOF > /usr/share/applications/jetbrains-toolbox.desktop
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=/opt/jetbrains-toolbox
Icon=/opt/jetbrains-toolbox.png
EOF'

out "Miscellaneous tweaks"
#

profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1}

conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/visible-name" "'GioBatta'"
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/default-size-columns" 120
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/default-size-rows" 28
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/audible-bell" false
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/background-color" "'rgb(23,20,33)'"
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/foreground-color" "'rgb(208,207,204)'"
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/palette" "['rgb(46,52,54)', 'rgb(204,0,0)', 'rgb(78,154,6)', 'rgb(196,160,0)', 'rgb(52,101,164)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']"
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/font" "'Fira Code 10'"
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/use-transparent-background" true
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/use-theme-colors" true
conf_write "/org/gnome/terminal/legacy/profiles:/:$profile/background-transparency-percent" 8
log "+" "Applied: terminal settings"

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash &> /dev/null
echo 'fastfetch' >> ~/.bashrc

# // Prepare and Exit
echo -e "${green}Done!${RESET}"
