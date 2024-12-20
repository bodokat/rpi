{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  hostname = "berni-pi.tailb15778.ts.net";
  services = {
    radarr = {
      orig = 7878;
      caddy = 7879;
    };
    sonarr = {
      orig = 8989;
      caddy = 8990;
    };
    prowlarr = {
      orig = 9696;
      caddy = 9697;
    };
    i2pd = rec {
      orig = config.services.i2pd.proto.http.port;
      caddy = orig + 1;
    };
    jellyfin = {
      orig = 8096;
      caddy = 8097;
    };
    jellyseerr = rec {
      orig = config.services.jellyseerr.port;
      caddy = orig + 1;
    };
    qbittorrent-vpn = rec {
      orig = config.services.qbittorrent.vpn.port;
      caddy = orig + 1;
      extraConfig = ''
        reverse_proxy 192.168.15.1:${toString orig} {
          header_up X-Forwarded-Host {host}:${toString caddy}
          header_up -Origin
          header_up -Referer
        }
      '';
      ip = "192.168.15.1";
    };
    qbittorrent-i2p = rec {
      orig = config.services.qbittorrent.i2p.port;
      caddy = orig + 1;
    };
    deluge = rec {
      orig = config.services.deluge.web.port;
      caddy = orig + 1;
      extraConfig = ''
        reverse_proxy 192.168.15.1:${toString orig}
      '';
    };
  };
in
{

  users.groups."media" = { };

  users.users."media" = {
    group = "media";
    isSystemUser = true;
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
      group = "media";
    };
    vpn = {
      port = 8090;
      user = "media";
      group = "media";
    };
  };
  systemd.services.qbittorrent-vpn.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  services.deluge = {
    enable = true;
    web.enable = true;
  };
  systemd.services.deluged.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };
  systemd.services.delugeweb.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  # needed for radarr/sonarr
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    user = "media";
    group = "media";
  };

  services.sonarr = {
    enable = true;
    user = "media";
    group = "media";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "media";
    group = "media";
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.jellyseerr = {
    image = "fallenbagel/jellyseerr:latest";
    environment = {
      LOG_LEVEL = "debug";
      TZ = "Europe/Vienna";
      PORT = "5055";
    };
    ports = [ "5055:5055" ];
    networks = [ "host" ];
    volumes = [ "/var/lib/jellyseerr-docker:/app/config" ];
  };
  # services.jellyseerr = {
  #   enable = true;
  # };

  services.homepage-dashboard = {
    enable = true;
    services = [
      {
        "Services" = lib.mapAttrsToList (name: value: {
          ${name} = {
            href = "https://${hostname}:${toString value.caddy}";
          };
        }) services;
      }
    ];
  };

  services.caddy = {
    enable = true;
    virtualHosts =
      (lib.mapAttrs' (
        name: value:
        lib.nameValuePair "https://${hostname}:${toString value.caddy}" {
          extraConfig = (
            value.extraConfig or ''
              reverse_proxy localhost:${toString value.orig}
            ''
          );
        }
      ) services)
      // {
        "https://${hostname}" = {
          # serverAliases = [ "berni-pi" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.homepage-dashboard.listenPort}
          '';
        };
      };
  };

  age.secrets.ts-authkey = {
    file = ./secrets/ts-authkey.age;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
    mode = "600";
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.ts-authkey.path;
  services.tailscale.permitCertUid = config.services.caddy.user;

  age.secrets."protonvpn.conf".file = ./secrets/protonvpn.conf.age;
  age.secrets."protonvpn_key".file = ./secrets/protonvpn_key.age;

  networking.firewall.allowedTCPPorts = [
    6881
    6889
    51820
  ];
  networking.firewall.allowedUDPPorts = [
    6881
    6889
    51820
  ];

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
        (mkPort config.services.qbittorrent.vpn.port)
        (mkPort config.services.deluge.web.port)
      ];

    openVPNPorts = [
      {
        port = 51413;
        protocol = "both";
      }
      {
        port = 2686;
        protocol = "both";
      }
      {
        port = 6881;
        protocol = "both";
      }
      {
        port = 6889;
        protocol = "both";
      }
    ];
  };
}
