# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  hostName,
  userName,
  ...
}: let
  secretsDir = "/etc/nixos/secrets";
in {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "@wheel"];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    nix-ld = {
      enable = true;
      libraries = [
        # CLion
        pkgs.icu
      ];
    };
    zsh.enable = true;
    fish.enable = true;
  };

  users.mutableUsers = false;
  users.users.root = {
    hashedPasswordFile = "${secretsDir}/root_password_hash";
  };
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPasswordFile = "${secretsDir}/user_password_hash";
    shell = pkgs.zsh;
  };
}
