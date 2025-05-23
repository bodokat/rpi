{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    serverProperties = {
      difficulty = "normal";
      level-name = "Berni's Minecraft Server";
      motd = "Hi";
    };
  };
}
