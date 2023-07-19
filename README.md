# Aleksi's Debian setup

- Debian 12 or newer.
- SDDM and lightweight XFCE4 desktop.
- Small tweaks for polkit and .profile.
- Preferences for apt. 

Requires clean Debian base installation with Standard System Utilities.

https://cdimage.debian.org/debian-cd/current/

# Automated script (WIP) 

After base Debian installation, you can run a script to use this setup:
```
wget https://aleksiaksu.github.io/debsetup/setup_script.sh && bash ./setup_script.sh 
```

# Manual installation (Based on notes.)

Install `git`.
```
sudo apt install git
```
Copy preferences for `apt`:
```
git clone https://github.com/aleksiaksu/aptprefs.git ~/aptprefs
cd ~/aptprefs/debian
sudo cp *.pref /etc/apt/preferences.d
sudo apt update
```

To install desktop with applications, use:
```
sudo apt install sddm --no-install-recommends
sudo apt install pulseaudio xfce4-session xfce4-panel xfce4-pulseaudio-plugin \
 xfce4-power-manager xfce4-power-manager-data xfce4-power-manager-plugins \
 policykit-1 policykit-1-gnome polkitd pkexec policycoreutils
sudo apt install blender galculator gimp flatpak mousepad gnome-disk-utility pcmanfm lxterminal vlc xterm
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub org.mozilla.firefox
```

You'll need to restart the computer.

Set `firefox` as the default web browser.
```
sudo update-alternatives --install /usr/bin/x-web-browser x-web-browser /var/lib/flatpak/exports/bin/org.mozilla.firefox 201
```

Copy configuration files for `polkit`:
```
git clone https://github.com/aleksiaksu/debsetup.git ~/debsetup
cd ~/debsetup
sudo cp *.conf /etc/polkit-1/localauthority.conf.d
```

Include `/usr/sbin` in PATH:
```
cat <<EOF >> ~/.profile
# set PATH so it includes sbin if it exists
if [ -d "/usr/sbin" ] ; then
    PATH="/usr/sbin:$PATH"
fi
EOF
```

You'll need to restart the computer.

Optional, for gaming:

I recommend to install Steam Launcher via apt with recommended packages:
```
sudo sh -c "tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF" && \
sudo wget -O /usr/share/keyrings/steam.gpg https://repo.steampowered.com/steam/archive/stable/steam.gpg && \
sudo dpkg --add-architecture i386 && \
sudo apt-get update && \
sudo apt install steam-launcher --install-recommends
```
Press "Y" and Enter to continue.

Source: https://repo.steampowered.com/steam/

Disclaimer: Yourself is responsible for changes to your computer. Remember to make the necessary backups.
