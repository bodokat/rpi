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
    portMappings = [
      (
        let
          p = config.services.transmission.settings.rpc-port;
        in
        {
          from = p;
          to = p;
        }
      )
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

  # networking.wireguard.interfaces.protonvpn =
  #   let
  #     nsname = "proton";
  #   in
  #   {
  #     preSetup = ''
  #       ip netns add ${nsname} || true
  #       ip -n ${nsname} link set lo up
  #     '';
  #     peers = [
  #       {
  #         publicKey = "a8iW00DUux7FfnJaJaok3BgbcrQje4s3JiDp4OEVnnA=";
  #         endpoint = "138.199.7.250:51820";
  #         allowedIPs = [
  #           "0.0.0.0/0"
  #           "::/0"
  #         ];
  #       }
  #     ];
  #     privateKeyFile = "/var/secrets/protonvpn_key";
  #     ips = [ "10.2.0.2" ];
  #     listenPort = 32;
  #     interfaceNamespace = nsname;
  #   };

}
