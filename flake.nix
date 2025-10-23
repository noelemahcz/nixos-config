{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  }: let
    hostName = "nixos";
    userName = "noelemahcz";
    userEmail = "noelemahcz@outlook.com";
  in {
    nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit hostName userName;};
      modules = [
        ./wsl.nix
        ./networking.nix
        nixos-wsl.nixosModules.default
        {
          system.stateVersion = "24.11";
          wsl = {
            enable = true;
            defaultUser = userName;
            wslConf.interop.appendWindowsPath = false;
            extraBin = [
              {
                src = "/mnt/c/Users/ZCham/scoop/shims/win32yank.exe";
                copy = false;
              }
            ];
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {inherit userName userEmail;};
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${userName} = ./home.nix;
        }
      ];
    };
  };
}
