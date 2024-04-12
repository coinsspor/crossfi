#!/bin/bash

# Prompt for nodename and set environment variables
echo "Please enter your nodename (validator moniker):"
read NODENAME
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile

# Set wallet environment variable if not set
if [ -z "$WALLET" ]; then
    echo "export WALLET=wallet" >> $HOME/.bash_profile
fi

echo "export CROSSFI_CHAIN_ID=mineplex-mainnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install curl build-essential git wget jq make gcc tmux net-tools ccze -y

# Install Go only if it is not already installed
if ! command -v go &> /dev/null; then
    ver="1.20.2"
    wget "https://go.dev/dl/go$ver.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
    source ~/.bash_profile
fi

# Download and setup the Crossfi node
wget https://github.com/crossfichain/crossfi-node/releases/download/v0.1.1/mineplex-2-node_v0.1.1_linux_amd64.tar.gz
tar -xzf mineplex-2-node_v0.1.1_linux_amd64.tar.gz
mv mineplex-chaind $HOME/go/bin/crossfid
rm mineplex-2-node_v0.1.1_linux_amd64.tar.gz

# Initialize the application
crossfid init $NODENAME --chain-id $CROSSFI_CHAIN_ID
git clone https://github.com/crossfichain/mainnet.git
mkdir -p $HOME/.mineplex-chain/config
cp -r $HOME/mainnet/config/* $HOME/.mineplex-chain/config

# Download configuration files from the GitHub repository
wget https://raw.githubusercontent.com/coinsspor/crossfi/main/mainnet/genesis.json -O $HOME/.mineplex-chain/config/genesis.json
wget https://raw.githubusercontent.com/coinsspor/crossfi/main/mainnet/addrbook.json -O $HOME/.mineplex-chain/config/addrbook.json

# Configure pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mineplex-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mineplex-chain/config/app.toml

# Create and register the systemd service
sudo tee /etc/systemd/system/crossfid.service > /dev/null <<EOF
[Unit]
Description=Crossfi node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.mineplex-chain
ExecStart=/usr/local/go/bin/crossfid start --home $HOME/.mineplex-chain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable crossfid
sudo systemctl restart crossfid && sudo journalctl -u crossfid -f -o cat
