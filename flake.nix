{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { nixpkgs, ... }:

  let

    system = "x86_64-linux";

        
  in {
    nixosConfigurations = {
      B490 = nixpkgs.lib.nixosSystem {
      	inherit system;

      	modules = [
      	  ./configuration.nix	
      	];
      };	
    };
  };
}
