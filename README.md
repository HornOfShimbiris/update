#!/usr/bin/env bash
set -euo pipefail

echo "Starting Kali Live session setup..."

# 1️⃣ Update packages
echo "[*] Updating package lists..."
sudo apt update -y
sudo apt upgrade -y

# 2️⃣ Install Tor + Tor Browser
echo "[*] Installing Tor..."
sudo apt install -y tor torbrowser-launcher
sudo systemctl start tor

# 3️⃣ Install VPN tools (OpenVPN)
echo "[*] Installing VPN tools..."
sudo apt install -y openvpn network-manager-openvpn

# 4️⃣ Install Broadcom Wi-Fi driver for session
echo "[*] Installing Broadcom Wi-Fi driver..."
sudo apt install -y broadcom-sta-dkms
sudo modprobe -r b44 b43 b43legacy ssb bcma || true
sudo modprobe wl || true

# 5️⃣ Install Synaptics driver for trackpad tap-click & right-click
echo "[*] Installing Synaptics touchpad driver..."
sudo apt install -y xserver-xorg-input-synaptics

# 6️⃣ Reload touchpad module
sudo modprobe -r psmouse || true
sudo modprobe psmouse || true

# 7️⃣ Configure tap-to-click and two-finger right click for this session
mkdir -p ~/.config/xorg.conf.d
cat <<EOL > ~/.config/xorg.conf.d/70-synaptics.conf
Section "InputClass"
    Identifier "touchpad catchall"
    Driver "synaptics"
    MatchIsTouchpad "on"
    Option "TapButton1" "1"       # single tap = left click
    Option "TapButton2" "3"       # two-finger tap = right click
EndSection
EOL

# 8️⃣ Restart GUI to apply touchpad changes
echo "[*] Restarting GUI to apply touchpad settings..."
sudo systemctl restart gdm3 || echo "GUI restart failed. Log out and back in to apply."

# 9️⃣ Show network interfaces
echo "[*] Network interfaces:"
ip a

echo "✅ Kali Live session setup complete!"
echo "You can now use Wi-Fi (if driver loaded), Tor, VPN, and basic trackpad clicks."
echo "Remember: everything resets on reboot in Live mode."
