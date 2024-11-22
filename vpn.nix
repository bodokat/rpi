{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{

  age.secrets."protonvpn.conf".file = ./secrets/protonvpn.conf.age;

  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.age.secrets."protonvpn.conf".path;
    accessibleFrom = [
      "192.168.0.0/24"
    ];
    portMappings =
    let mkPort = p: {from = p; to = p;}; in
    [
      (mkPort config.services.transmission.settings.rpc-port)
      #prowlarr
      (mkPort 9696)
    ];

    openVPNPorts = [
      {
        port = config.services.transmission.settings.peer-port;
        protocol = "both";
      }
    ];
  };

  systemd.services.transmission = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
  };


  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    settings = {
      rpc-bind-address = "192.168.15.1";
      rpc-whitelist = "192.168.*.*,127.0.0.1, 100.107.125.50";
      rpc-host-whitelist = "berni-pi";
      # rpc-whitelist-enabled = false;
    };
  };
}
