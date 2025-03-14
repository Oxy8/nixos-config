{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-software-center.url = "github:vlinkz/nix-software-center";
  };

  outputs = { nixpkgs, nix-software-center, ... }@inputs:

	{
		nixosConfigurations = {

			B490 = nixpkgs.lib.nixosSystem {
			
		      	system = "x86_64-linux";
		      	specialArgs = { inherit inputs; };
		      	modules = [ ./configuration.nix ];
		      	
			};	
		};
	};
}
