{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  networking.wireguard.interfaces.protonvpn =
    let
      nsname = "proton";
    in
    {
      preSetup = ''
        ip netns add ${nsname} || true
        ip -n ${nsname} link set lo up
      '';
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
      interfaceNamespace = nsname;
    };

}
