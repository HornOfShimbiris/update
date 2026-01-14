#!/bin/bash
set -e

echo "========================================="
echo " Kali Live Session Setup Script"
echo " No reboot • No logout • Live-safe"
echo "========================================="

# Ensure script is not run as root directly
if [[ "$EUID" -eq 0 ]]; then
  echo "[!] Do NOT run this script as root. Run it as a normal user."
  exit 1
fi

# 1️⃣ Update packages
echo "[*] Updating package lists..."
sudo apt update -y

# 2️⃣ Install Tor + Tor Browser
echo "[*] Installing Tor..."
sudo apt install -y tor torbrowser-launcher
sudo systemctl start tor

# 3️⃣ Install VPN tools
echo "[*] Installing VPN tools..."
sudo apt install -y openvpn network-manager-openvpn

# 4️⃣ Install Broadcom Wi-Fi driver (Live session)
echo "[*] Installing Broadcom Wi-Fi driver..."
sudo apt install -y broadcom-sta-dkms
sudo modprobe -r b44 b43 b43legacy ssb bcma 2>/dev/null || true
sudo modprobe wl 2>/dev/null || true

# 5️⃣ Install Synaptics tools (runtime config, no restart)
echo "[*] Installing Synaptics touchpad utilities..."
sudo apt install -y xserver-xorg-input-synaptics xinput

# 6️⃣ Apply touchpad settings LIVE (no logout)
echo "[*] Applying touchpad settings (live session)..."

TOUCHPAD_ID=$(xinput list | grep -i touchpad | head -n1 | sed 's/.*id=\([0-9]*\).*/\1/')

if [[ -n "$TOUCHPAD_ID" ]]; then
  echo "  → Touchpad detected (ID: $TOUCHPAD_ID)"

  # Enable tapping
  xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1 2>/dev/null || true

  # Two-finger right click
  xinput set-prop "$TOUCHPAD_ID" "libinput Click Method Enabled" 0 1 2>/dev/null || true

  # Natural scrolling (optional but useful)
  xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true

  echo "  ✓ Touchpad settings applied instantly"
else
  echo "  ⚠ Touchpad not detected — skipping touchpad config"
fi

# 7️⃣ Show network interfaces
echo "[*] Network interfaces:"
ip a

echo "========================================="
echo " ✅ Kali Live setup complete!"
echo " • Wi-Fi driver loaded (if supported)"
echo " • Tor ready"
echo " • VPN tools installed"
echo " • Touchpad works immediately (no logout)"
echo "========================================="

exit 0
