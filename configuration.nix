{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.nixosManual.enable = true;

  networking.hostName = "pi";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8diTl0La1Yyv4OwSZBpnZrESv6edKsNze1Z88u4U5a bod.kato@gmail.com"
  ];

  # users.users.berni = {
  #       isNormalUser = true;
  #       extraGroups = [ "wheel" ];
  #       openssh.authorizedKeys.keys = [
  #           # This is my public key
  #           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8diTl0La1Yyv4OwSZBpnZrESv6edKsNze1Z88u4U5a bod.kato@gmail.com"
  #         ];
  # };

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    inputs.helix.packages."${pkgs.system}".helix
    git
  ];

  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };
  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  system.stateVersion = "24.11";
}
