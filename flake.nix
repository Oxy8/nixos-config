{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-software-center.url = "github:vlinkz/nix-software-center";
  };

  outputs = { nixpkgs, nix-software-center, home-manager, ... }@inputs:

	{
		nixosConfigurations = {

			B490 = nixpkgs.lib.nixosSystem {
			
		      	system = "x86_64-linux";
		      	specialArgs = { inherit inputs; };
		      	modules = [ ./B490/configuration.nix ];
		      	
			};

			V15 = nixpkgs.lib.nixosSystem {
							
		      	system = "x86_64-linux";
		      	specialArgs = { inherit inputs; };
		      	modules = [
		      		./V15/configuration.nix
					./V15/keyboard-led-update.nix
		      	];
		      	
			};
				
		};
		
		nixosModules = {
		# ...
			declarativeHome = { ... }: {
				config = {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
				};
			};
		};

	};
}
