{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./vpn.nix
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/var/secrets/tailscale_key";
  };

  documentation.nixos.enable = true;

  networking.hostName = "berni-pi";

  security.sudo.enable = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8diTl0La1Yyv4OwSZBpnZrESv6edKsNze1Z88u4U5a bod.kato@gmail.com"
  ];

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
  ];

  services.deluge = {
    enable = true;
    web.enable = true;
    web.openFirewall = true;

    openFirewall = true;
  };

  services.jackett = {
    enable = true;

  };

  services.radarr = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
  };

  services.jellyseerr = {
    enable = true;
  };

  services.i2pd = {
    enable = true;
  };

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
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "github:bodokat/rpi";
  };

  nix.package = pkgs.lix;
  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  system.stateVersion = "24.11";
}
