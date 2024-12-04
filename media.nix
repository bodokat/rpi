{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{

  users.groups."media" = {};

  users.users."media" = {
    group = "media";
  };

  systemd.tmpfiles.settings."10-media" = {
    "/var/lib/media".d = {
      user = "media";
      group = "media";
    };
  };


  services.qbittorrent = {
      enable = true;
      openFirewall = true;
      i2p = {
        port = 8080;
        user = "media";
      };
      vpn = {
        port = 8090;
        user = "media";
      };
    };
    systemd.services.qbittorrent-vpn.vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    services.radarr = {
      enable = true;
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.sonarr = {
      enable = true;
      openFirewall= true;
      user = "media";
      group = "media";
    };


    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

  age.secrets."protonvpn.conf".file = ./secrets/protonvpn.conf.age;
  age.secrets."protonvpn_key".file = ./secrets/protonvpn_key.age;

  networking.firewall.allowedUDPPorts = [51820];

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets."protonvpn.conf".path;
    accessibleFrom = [
      "192.168.0.0/24"
      "127.0.0.0/24"
    ];
    portMappings =
    let mkPort = p: {from = p; to = p;}; in
    [
      (mkPort config.services.transmission.settings.rpc-port)
      (mkPort config.services.qbittorrent.vpn.port)
    ];

    openVPNPorts = [
      {
        port = config.services.transmission.settings.peer-port;
        protocol = "both";
      }
      {
        port = 51413;
        protocol = "both";
      }
      {
        port = 2686;
        protocol = "both";
      }
    ];
  };



  # systemd.services.transmission = {
  #   vpnConfinement = {
  #     enable = true;
  #     vpnNamespace = "wg";
  #   };
  # };


  # services.transmission = {
  #   enable = true;
  #   package = pkgs.transmission_4;

  #   settings = {
  #     rpc-bind-address = "192.168.15.1";
  #     rpc-whitelist = "192.168.*.*,127.0.0.1, 100.107.125.50";
  #     rpc-host-whitelist = "berni-pi";
  #     # rpc-whitelist-enabled = false;
  #   };
  # };
}
