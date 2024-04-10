# SNAPSHOT


`  sudo systemctl stop crossfid
  cp $HOME/.mineplex-chain/data/priv_validator_state.json $HOME/.mineplex-chain/priv_validator_state.json.backup
  rm -rf $HOME/.mineplex-chain/data
  SNAP_NAME="crossfi-snapshot-20240305.tar.lz4"
  curl http://crossfi-toolkit.coinsspor.com/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.mineplex-chain
  mv $HOME/.mineplex-chain/priv_validator_state.json.backup $HOME/.mineplex-chain/data/priv_validator_state.json
  sudo systemctl restart crossfid && journalctl -u crossfid -f --no-hostname -o cat`
  
  
