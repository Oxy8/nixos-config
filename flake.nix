{
  description = "Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-software-center.url = "github:vlinkz/nix-software-center";
    
    nix-xl.url = "github:passivelemon/nix-xl";
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
					
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						
						home-manager.users.estevan = { pkgs, ... }: {
							imports = [
								inputs.nix-xl.homeModules.nix-xl
							];
							
							home.stateVersion = "25.11"; 							  
							
							programs.lite-xl = {
								enable = true;
								fonts.font = "FiraCodeNerdFontMono-Retina";
								fonts.codeFont = "FiraCodeNerdFontMono-Retina";
							};							
						};
					}
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
