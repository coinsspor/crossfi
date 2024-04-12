#!/bin/bash

# Set variables
echo "Please enter your nodename (validator moniker):"
read NODENAME  # Kullanıcıdan nodename alır
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile

if [ -z "$WALLET" ]; then  # $WALLET değişkeni boş ise
    echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export CROSSFI_CHAIN_ID=mineplex-mainnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Update packages
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install curl build-essential git wget jq make gcc tmux net-tools ccze -y

# Install Go
if ! [ -x "$(command -v go)" ]; then
  ver="1.20.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

# Download and build binaries
cd $HOME
wget https://github.com/crossfichain/crossfi-node/releases/download/v0.1.1/mineplex-2-node._v0.1.1_linux_amd64.tar.gz
tar -xzfv mineplex-2-node_v0.1.1_linux_amd64.tar.gz
mv mineplex-chaind $HOME/go/bin/crossfid
rm -r mineplex-2-node_v0.1.1_linux_amd64.tar.gz

# Initialize the application
crossfid init $NODENAME --chain-id $CROSSFI_CHAIN_ID
git clone https://github.com/crossfichain/mainnet.git
cp -r $HOME/mainnet/config/* $HOME/.mineplex-chain/config

# Download configuration from the GitHub repository
wget https://raw.githubusercontent.com/coinsspor/crossfi/main/mainnet/genesis.json -O $HOME/.mineplex-chain/config/genesis.json
wget https://raw.githubusercontent.com/coinsspor/crossfi/main/mainnet/addrbook.json -O $HOME/.mineplex-chain/config/addrbook.json

# Config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mineplex-chain/config/app.toml

# Create and register service
sudo tee /etc/systemd/system/crossfid.service > /dev/null <<EOF
[Unit]
Description=Crossfi node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.mineplex-chain
ExecStart=$(which crossfid) start --home $HOME/.mineplex-chain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Register and start service
sudo systemctl daemon-reload
sudo systemctl enable crossfid
sudo systemctl restart crossfid && sudo journalctl -u crossfid -f -o cat
