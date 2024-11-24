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
    ./qbittorrent.nix
    #./minecraft.nix
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

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.prowlarr.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  services.deluge ={
    enable = true;
    openFirewall = true;
    web.enable = true;
    web.openFirewall = true;
  };



  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.i2pd = {
    enable = true;
    proto.httpProxy = {
      enable = true;
      address = "192.168.75.155";
    };
    proto.http = {
      enable = true;
      address = "0.0.0.0";
      strictHeaders = false;
      hostname = config.networking.hostName;
    };
    proto.sam.enable = true;

  };
  services.veilid = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.allowedTCPPorts = [
    # i2pd http proxy
    4444
    # nginx
    80
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts.berni-pi = {
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
      locations."/i2pd/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.i2pd.proto.http.port}/";
      };
      locations."/qbittorrent/" = {
        #proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.port}";
        proxyPass = "http://127.0.0.1:8080/";

      };
      locations."/jellyfin/" = {
        proxyPass = "http://127.0.0.1:8096/";
      };
      locations."/jellyseerr/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.jellyseerr.port}/";
      };
      locations."/radarr/" = {
        proxyPass = "http://127.0.0.1:7878/";
      };
      locations."/jackett/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.jackett.port}/";
      };
    };
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
