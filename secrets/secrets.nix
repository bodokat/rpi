let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8diTl0La1Yyv4OwSZBpnZrESv6edKsNze1Z88u4U5a";
  berni-pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDwkdTAX2QqYfRodjPVNNcY+B1rXqNpAcjBgUasqmdR";
in
{
  "protonvpn.conf.age".publicKeys = [laptop berni-pi];
  "protonvpn_key.age".publicKeys = [laptop berni-pi];
}
