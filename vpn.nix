{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{

  age.secrets."protonvpn.conf".file = ./secrets/protonvpn.conf.age;
  age.secrets."protonvpn_key".file = ./secrets/protonvpn_key.age;

  networking.firewall.allowedUDPPorts = [51820];

  # networking.iproute2.enable = true;
  # networking.iproute2.rttablesExtraConfig = ''
  #   200 isp2
  # '';

  # networking.wireguard.enable = true;
  # networking.wireguard.interfaces."wg0" = {
  #   ips = [ "10.2.0.2/32" ];
  #   listenPort = 51820;
  #   allowedIPsAsRoutes = false;

  #   # table = 1000;

  #   # postSetup = [
  #   #   "ip -4 route change default via 10.2.0.1 table 1000"
  #   #   "ip -4 rule add priority 1 from 10.2.0.2 table 1000"
  #   # ];

  #   # postShutdown = [
  #   #   "ip -4 rule del priority 1 from 10.2.0.2 table 1000"
  #   # ];

  #   privateKeyFile = config.age.secrets.protonvpn_key.path;

  #   peers = [{
  #     allowedIPs = [ "0.0.0.0/0" "::/0" ];
  #     # allowedIPs = [ "0.0.0.0/5" " 8.0.0.0/7" " 11.0.0.0/8" " 12.0.0.0/6" " 16.0.0.0/4" " 32.0.0.0/3" " 64.0.0.0/2" " 128.0.0.0/3" " 160.0.0.0/5" " 168.0.0.0/6" " 172.0.0.0/12" " 172.32.0.0/11" " 172.64.0.0/10" " 172.128.0.0/9" " 173.0.0.0/8" " 174.0.0.0/7" " 176.0.0.0/4" " 192.0.0.0/9" " 192.128.0.0/11" " 192.160.0.0/13" " 192.169.0.0/16" " 192.170.0.0/15" " 192.172.0.0/14" " 192.176.0.0/12" " 192.192.0.0/10" " 193.0.0.0/8" " 194.0.0.0/7" " 196.0.0.0/6" " 200.0.0.0/5" " 208.0.0.0/4" ];
  #     publicKey = "FUnwfgDQWcuTC3BacXUv9hZhkNWywecdsJz2c4FZJCI=";
  #     endpoint = "91.207.174.2:51820";
  #     persistentKeepalive = 25;
  #   }];
  # };

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
      #prowlarr
      # (mkPort 9696)
      #radarr
      # (mkPort 7878)
      (mkPort config.services.qbittorrent.vpn.port)
      (mkPort 8090)
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
