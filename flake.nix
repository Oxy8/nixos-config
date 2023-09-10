{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { nixpkgs, ... }:

  let

    system = "x86_64-linux";
    
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
      	inherit system;

      	modules = [
      	  ./configuration.nix	
      	];
      };	
    };
  };
}
