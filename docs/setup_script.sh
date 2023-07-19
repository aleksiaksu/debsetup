#!/bin/bash

echo "Welcome to setup. Script by github/aleksiaksu."
echo "The script is licensed under MIT."
echo "The script installs lightweight XFCE4 desktop with SDDM."
echo "Optional software can be installed."
echo "You need to set manually desktop settings, after installation."

# Prompt for user confirmation to proceed
read -p "Do you want to proceed? [Y/n]: " choiceSetup
choiceSetup=${choiceSetup,,}  # Convert the input to lowercase

# Prompt for user confirmation for Desktop installation
read -p "Do you want to install Desktop? [Y/n]: " choiceDesktop
choiceDesktop=${choiceDesktop,,}  # Convert the input to lowercase

# Prompt for user confirmation for Steam installation
read -p "Do you want to install Steam? [Y/n]: " choiceSteam
choiceSteam=${choiceSteam,,}  # Convert the input to lowercase

# Prompt for user confirmation for Network Manager installation
read -p "Do you want to install Network Manager? [Y/n]: " choiceNetworkManager
choiceNetworkManager=${choiceNetworkManager,,}  # Convert the input to lowercase

# Prompt for user confirmation for Wine installation
read -p "Do you want to install Wine and run Win programs? [Y/n]: " choiceInsWine
choiceInsWine=${choiceInsWine,,}  # Convert the input to lowercase

# Prompt for user confirmation for Terminal Extras installation
read -p "Do you want to install Terminal Extras? [Y/n]: "  choiceInsTermExtras
 choiceInsTermExtras=${choiceInsTermExtras,,}  # Convert the input to lowercase

if [[ $choiceSetup =~ ^(y|yes|)$ ]]; then

# Enable I386 architecture
echo "Enabling i386 architecture"
sudo dpkg --add-architecture i386 

# Install git
echo "Installing git..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install git

# Clone debprefs repository
echo "Cloning apt preferences from Github..."
git clone https://github.com/aleksiaksu/aptprefs.git ~/aptprefs
cd ~/aptprefs/debian

# Copy preferences
echo "Setting up apt preferences.."
sudo cp *.pref /etc/apt/preferences.d

# Update apt repositories
echo "Running apt update..."
sudo apt update

# Desktop installation START  

# Desktop
if [[ $choiceDesktop =~ ^(y|yes|)$ ]]; then

# Install sddm without recommended packages
echo "Installing sddm without recommended packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install sddm --no-install-recommends

# Install required packages
echo "Installing required packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install pulseaudio xfce4-session xfce4-panel xfce4-pulseaudio-plugin \
xfce4-power-manager xfce4-power-manager-data xfce4-power-manager-plugins \
policykit-1 policykit-1-gnome polkitd pkexec policycoreutils

# Install additional packages
echo "Installing additional packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install blender galculator gimp flatpak mousepad gnome-disk-utility \
pcmanfm lxterminal vlc xterm

# Add Flathub repository
echo "Adding Flathub repository..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Firefox from Flathub
echo "Installing Firefox from Flathub..."
sudo flatpak install -y --noninteractive flathub org.mozilla.firefox

# Set up Firefox as the default browser
echo "Setting up Firefox as the default browser..."
sudo update-alternatives --install /usr/bin/x-web-browser x-web-browser \
/var/lib/flatpak/exports/bin/org.mozilla.firefox 201

else
echo "Desktop installation cancelled."
fi

# Desktop installation END

# Clone deb-setup repository
git clone https://github.com/aleksiaksu/debsetup.git ~/debsetup
cd ~/debsetup

# Copy polkit configuration 
echo "Setting up polkit admin privileges for sudo group..."
sudo cp *.conf /etc/polkit-1/localauthority.conf.d

# Append PATH configuration to ~/.profile
echo "Adding small tweak to PATH..."
sh -c 'cat <<EOF >> ~/.profile
# set PATH so it includes sbin if it exists
if [ -d "/usr/sbin" ] ; then
    PATH="/usr/sbin:$PATH"
fi
EOF'

# Optional software START  

# Steam
if [[ $choiceSteam =~ ^(y|yes|)$ ]]; then
# Configure Steam repository
echo "Configuring Steam repository..."
sudo sh -c "tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF"

# Download and import Steam repository keyring
echo "Importing Steam repository key..."
sudo wget -O /usr/share/keyrings/steam.gpg https://repo.steampowered.com/steam/archive/stable/steam.gpg
sudo dpkg --add-architecture i386
sudo apt-get update

# Install Steam launcher with recommended packages
echo "Installing Steam with recommended packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install steam-launcher --install-recommends
else
echo "Steam installation cancelled."
fi

# Network Manager
if [[ $choiceNetworkManager =~ ^(y|yes|)$ ]]; then
echo "Installing Network Manager..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install network-manager network-manager-config-connectivity-debian
sudo systemctl stop NetworkManager
echo "Removing lines from /etc/network/interfaces..."
sudo sed -i '10,$ d' /etc/network/interfaces
echo "Setting network to managed..."
sudo sed -i 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl start NetworkManager
else
echo "Network Manager installation cancelled."
fi

# Wine
if [[ $choiceInsWine =~ ^(y|yes|)$ ]]; then
echo "Importing winehq repository key..."
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
echo "Adding winehq repository"
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
sudo apt-get update
echo "Installing Wine with recommended packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install winehq-stable
echo "Installing winetricks..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install zenity
sudo bash -c 'wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && chmod +x /usr/local/bin/winetricks'
else
echo "Wine installation cancelled."
fi

#  Terminal Extras 
if [[ $choiceInsTermExtras =~ ^(y|yes|)$ ]]; then
echo "Installing Terminal Extras..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install htop lshw neofetch
else
echo "Terminal Extras installation cancelled."
fi

# Optional software END

echo "Setup result:"
if [[ $choiceNetworkManager =~ ^(y|yes|)$ ]]; then
echo "You can manage your network configuration, by running the commands: nmtui for GUI or nmcli for text only."
fi
if [[ $choiceInsWine =~ ^(y|yes|)$ ]]; then
echo "You can run certain Win programs. You can tweak Wine, by running the command: winetricks."
fi

echo "Please restart your computer. Please run: sudo reboot"

else
echo "Installation cancelled."
fi
