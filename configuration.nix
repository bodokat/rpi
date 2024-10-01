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

  documentation.nixos.enable = true;

  networking.hostName = "pi";

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

  networking.wg-quick.interfaces.protonvpn = {
    autostart = true;
    address = [ "10.2.0.2" ];
    listenPort = 32;
    privateKey = "mFkBhnjSlGoqGMVQ+r+ur51aKVQ8/wYjpymPtRYPAEE=";

    peers = [
      {
        publicKey = "+kfPCjoNEateo3jVc9tcduKh6nwQpoKx0/JXxgjHD2c=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "190.2.147.7:51820";
      }
    ];
  };

  #   [Interface]
  # # Key for Server
  # # Bouncing = 1
  # # NAT-PMP (Port Forwarding) = off
  # # VPN Accelerator = on
  # PrivateKey = mFkBhnjSlGoqGMVQ+r+ur51aKVQ8/wYjpymPtRYPAEE=
  # Address = 10.2.0.2/32
  # DNS = 10.2.0.1

  # [Peer]
  # # NL-FREE#345073
  # PublicKey = +kfPCjoNEateo3jVc9tcduKh6nwQpoKx0/JXxgjHD2c=
  # AllowedIPs = 0.0.0.0/0
  # Endpoint = 190.2.147.7:51820

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
