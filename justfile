default:
  just --list

deploy:
  SHELL="/bin/bash" nix run github:serokell/deploy-rs .#berni-pi


agenix +args:
  cd secrets && nix run github:ryantm/agenix -- {{args}}
