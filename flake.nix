{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

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

			Lab245 = nixpkgs.lib.nixosSystem {
			
		      	system = "x86_64-linux";
		      	specialArgs = { inherit inputs; };
		      	modules = [ ./Lab245/configuration.nix ];
		      	
			};
		};
	};
}
