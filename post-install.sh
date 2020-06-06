#!/bin/bash

# Install favorite packages
sudo bash -c 'apt-get update -y && \
              apt-get dist-upgrade -y && \
              apt-get install -y \
              zsh jq curl wget magic-wormhole fonts-hack fonts-hack-ttf vim tmux openvpn ipython3 adb flameshot seclists libnss3-tools  '

# VSCODE
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

# DOCKER
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list

# Google-Chrome
curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Install VSCODE, DOCKER and CHROME
sudo bash -c 'apt-get update -y && apt-get dist-upgrade -y && apt-get install -y docker-ce code google-chrome-stable && sudo apt-get autoremove -y' 

# Add current user to docker, enable docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s $(which zsh) $USER

# Install croc
echo "[*] Installing croc"
croc_latest_location=$(curl -s "https://api.github.com/repos/schollz/croc/releases/latest" | jq -r '.assets[] | select(.browser_download_url | test("Linux-64bit.tar.gz")) | .browser_download_url')
curl -sL "$croc_latest_location"  | sudo tar --wildcards -C /usr/local/bin/ -xzf - 'croc'

# Install ffsend
echo "[*] Installing ffsend"
ffsend_latest_location=$(curl -s https://api.github.com/repos/timvisee/ffsend/releases/latest | jq -r '.assets[] | select(.browser_download_url | test("linux-x64-static")) | .browser_download_url')
sudo curl -sL "$ffsend_latest_location" -o "/usr/local/bin/ffsend"
sudo chmod a+x "/usr/local/bin/ffsend"

# Install bat
echo "[*] Installing bat"
bat_latest_location=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | jq -r '.assets[] | select(.browser_download_url | test("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')
curl -sL "$bat_latest_location"  | sudo tar --wildcards -C /usr/local/bin/ -xzf - --strip-components 1 '*/bat'

# Install burp
echo "[*] Downloading burp pro"
# wget 'https://portswigger.net/burp/releases/download?product=community&version=2020.4.1&type=Linux'
# http://127.0.0.1:5001/api/v0/pin/add?arg=QmWS4EKNnd8yTS2YDMV51QEBE4FUoDXZBTCMXfJ3Vrtgqf
BURP_DL_URL="https://cloudflare-ipfs.com/ipfs/QmWS4EKNnd8yTS2YDMV51QEBE4FUoDXZBTCMXfJ3Vrtgqf"
BURP_FILE="burpsuite_pro_linux_v2020_5.sh"
BURP_SHA256="1a915321fc15fa5374abed2965dfaf5e982325673d0f4deefbb53c2d6c5da6c2"
wget "$BURP_DL_URL" -O "$BURP_FILE" 
echo -ne "$BURP_SHA256\t$BURP_FILE" | sha256sum --check --status 

if [[ $? -eq 0 ]]
then
  echo "[*] Installing Burp Pro"
  bash "$BURP_FILE" -q
else
  echo "[*] Burp checksum failed... Not installing"
fi

# Install age
echo "[*] Installing age"
age_latest_location="https://github.com/FiloSottile/age/releases/download/v1.0.0-beta2/age-v1.0.0-beta2-linux-amd64.tar.gz"
# age_latest_location=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | jq -r '.assets[] | select(.browser_download_url | test("linux-amd64.tar.gz")) | .browser_download_url')
curl -sL $age_latest_location | sudo tar -xzf - -C /usr/local/bin --strip-components 1  age/age age/age-keygen
