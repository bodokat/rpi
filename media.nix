{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{

  users.groups."media" = { };

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
    openFirewall = true;
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

  services.dashy = {
    enable = true;
    settings = {
      pageInfo = {
        title = "Amogus";
        description = "ඞඞඞඞඞඞඞඞඞඞඞඞඞ";
      };
      sections = [
        {
          name = "lol";
          items = [
            {
              title = "qbittorrent (vpn)";
              icon = "si-qbittorrent";
              url = "berni-pi:${toString config.services.qbittorrent.vpn.port}";
            }
            {
              title = "qbittorrent (i2p)";
              icon = "si-qbittorrent";
              url = "berni-pi:${toString config.services.qbittorrent.i2p.port}";
            }
            {
              title = "jellyfin";
              icon = "si-qbittorrent";
              url = "berni-pi:8096";
            }
            {
              title = "jellyseerr";
              icon = "si-qbittorrent";
              url = "berni-pi:${toString config.services.jellyseerr.port}";
            }
            {
              title = "i2pd";
              icon = "hl-i2p-light";
              url = "berni-pi:${config.services.i2pd.proto.http.port}";
            }
            {
              title = "radarr";
              icon = "si-radarr";
              url = "berni-pi:7878";
            }
            {
              title = "sonarr";
              icon = "si-sonarr";
              url = "berni-pi:8989";
            }
            {
              title = "prowlarr";
              icon = "si-prowlarr";
              url = "berni-pi:9696";
            }
          ];
        }
      ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."berni-pi.tailb15778.ts.net".extraConfig = ''
      root ${config.services.dashy.finalDrv}
      try_files {path} /index.html
    '';
  };

  age.secrets."protonvpn.conf".file = ./secrets/protonvpn.conf.age;
  age.secrets."protonvpn_key".file = ./secrets/protonvpn_key.age;

  networking.firewall.allowedUDPPorts = [ 51820 ];

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets."protonvpn.conf".path;
    accessibleFrom = [
      "192.168.0.0/24"
      "127.0.0.0/24"
    ];
    portMappings =
      let
        mkPort = p: {
          from = p;
          to = p;
        };
      in
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
