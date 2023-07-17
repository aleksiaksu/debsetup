#!/bin/bash

echo "Welcome to setup. Script by github/aleksiaksu."
echo "The script is licensed under MIT."
echo "The script installs lightweight XFCE4 desktop with SDDM."
echo "You need to set manually desktop settings, after installation."

# Prompt for user confirmation
read -p "Do you want to proceed? [Y/n]: " choice1
choice1=${choice1,,}  # Convert the input to lowercase

# Prompt for user confirmation for Steam installation
read -p "Do you want to install Steam? [Y/n]: " choice2
choice2=${choice2,,}  # Convert the input to lowercase

if [[ $choice1 =~ ^(y|yes|)$ ]]; then
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

# Install sddm without recommended packages
echo "Installing sddm without recommended packages..."
sudo DEBIAN_FRONTEND=noninteractive apt -yq install sddm --no-install-recommends

# Install required packages
echo "Installing required packages..."
sudo DEBIAN_FRONTEND=noninteractive  apt -yq install pulseaudio xfce4-session xfce4-panel xfce4-pulseaudio-plugin \
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
    
    if [[ $choice2 =~ ^(y|yes|)$ ]]; then
    # Configure Steam repository
    echo "Configuring Steam repository..."
    sudo sh -c "tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
    deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
    deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
    EOF"
    
    # Download and import Steam repository keyring
    echo "Downloading Steam repository key..."
    sudo wget -O /usr/share/keyrings/steam.gpg https://repo.steampowered.com/steam/archive/stable/steam.gpg
    sudo dpkg --add-architecture i386
    sudo apt-get update
    
    # Install Steam launcher with recommended packages
    echo "Installing Steam with recommended packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt -yq install steam-launcher --install-recommends
    else
        echo "Steam installation cancelled."
    fi

echo "Please restart your computer. Run command: sudo reboot"

else
    echo "Installation cancelled."
fi
