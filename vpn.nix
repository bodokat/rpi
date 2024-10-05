{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  systemd.services.wg-proton = {
    description = "wg network interface (protonvpn)";
    bindsTo = [ "netns@proton.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@proton.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  networking.wireguard.interfaces.protonvpn =
    let
      nsname = "proton";
    in
    {
      preSetup = ''
        ip netns add ${nsname} || true
      '';
      # postShutdown = ''
      #   ip netns delete ${nsname}
      # '';
      peers = [
        {
          publicKey = "a8iW00DUux7FfnJaJaok3BgbcrQje4s3JiDp4OEVnnA=";
          endpoint = "138.199.7.250:51820";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
        }
      ];
      privateKeyFile = "/var/secrets/protonvpn_key";
      ips = [ "10.2.0.2" ];
      listenPort = 32;
      # interfaceNamespace = nsname;
    };

  # networking.wg-quick.interfaces.protonvpn = {
  #   autostart = true;
  #   address = [ "10.2.0.2" ];
  #   listenPort = 32;
  #   privateKeyFile = "/var/secrets/protonvpn_key";

  #   peers = [
  #     {
  #       publicKey = "a8iW00DUux7FfnJaJaok3BgbcrQje4s3JiDp4OEVnnA=";
  #       allowedIPs = [
  #         "0.0.0.0/0"
  #         "::/0"
  #       ];
  #       endpoint = "138.199.7.250:51820";
  #     }
  #   ];
  # };

}
