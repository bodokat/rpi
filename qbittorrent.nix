# Taken from: https://github.com/pceiley/nix-config/blob/main/hosts/common/modules/qbittorrent.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
qbt-service = name: {user, group, dataDir, port}: {
  # based on the plex.nix service module and
  # https://github.com/qbittorrent/qBittorrent/blob/master/dist/unix/systemd/qbittorrent-nox%40.service.in
  description = "qBittorrent-nox service (${name})";
  documentation = [ "man:qbittorrent-nox(1)" ];
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];

  serviceConfig = {
    Type = "simple";
    User = user;
    Group = group;

    AmbientCapabilities="CAP_NET_RAW";

    # Run the pre-start script with full permissions (the "!" prefix) so it
    # can create the data directory if necessary.
    ExecStartPre =
      let
        preStartScript = pkgs.writeScript "qbittorrent-run-prestart" ''
          #!${pkgs.bash}/bin/bash

          # Create data directory if it doesn't exist
          if ! test -d "$QBT_PROFILE"; then
            echo "Creating initial qBittorrent data directory in: $QBT_PROFILE"
            install -d -m 0755 -o "${user}" -g "${group}" "$QBT_PROFILE"
          fi
        '';
      in
      "!${preStartScript}";

    #ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
    ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=${dataDir} --webui-port=${toString port} --configuration=${name}
";
    # To prevent "Quit & shutdown daemon" from working; we want systemd to
    # manage it!
    #Restart = "on-success";
    #UMask = "0002";
    #LimitNOFILE = cfg.openFilesLimit;
  };

  environment = {
    QBT_PROFILE = dataDir;
    QBT_WEBUI_PORT = toString port;
  };
};
in
let
  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent =
  let
  service-cfg = name: {
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/qbittorrent-${name}";
      description = lib.mdDoc ''
        The directory where qBittorrent stores its data files.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent-${name}";
      description = lib.mdDoc ''
        User account under which qBittorrent runs.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent-${name}";
      description = lib.mdDoc ''
        Group under which qBittorrent runs.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = lib.mdDoc ''
        qBittorrent web UI port.
      '';
    };


  };
  in
  {
    enable = lib.mkEnableOption (lib.mdDoc "qBittorrent headless");

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    i2p = service-cfg "i2p";
    vpn = service-cfg "vpn";
  };

  config = lib.mkIf cfg.enable {



    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.i2p.port cfg.vpn.port ];
    };

    systemd.services.qbittorrent-i2p = qbt-service "i2p" cfg.i2p;

    systemd.services.qbittorrent-vpn = qbt-service "vpn" cfg.vpn;


    users.users.qbittorrent-i2p = lib.mkIf (cfg.i2p.user == "qbittorrent-i2p") {
        group = cfg.i2p.group;
        isSystemUser = true;
      };
    users.users.qbittorrent-vpn = lib.mkIf (cfg.vpn.user == "qbittorrent-vpn") {
          group = cfg.vpn.group;
          isSystemUser = true;
        };


    users.groups.qbittorrent-i2p = lib.mkIf (cfg.i2p.group == "qbittorrent-i2p") {};
    users.groups.qbittorrent-vpn = lib.mkIf (cfg.vpn.group == "qbittorrent-vpn") {};

  };
}
