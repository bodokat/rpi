deploy:
  SHELL="/bin/bash" bash -c "nix run github:serokell/deploy-rs .#berni-pi"
