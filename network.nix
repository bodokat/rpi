{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53; # Port for incoming DNS Queries.
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };

      customDns = {
        mapping = {
          "berni.sus" = "100.122.84.31";
        };
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "test.berni.sus".extraConfig = ''
        respond "Hi :3"
      '';
    };
  };

}
