{
  description = "Radiod package definition";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

	outputs = { self, nixpkgs }:
		let
			system = "x86_64-linux";
			pkgs = nixpkgs.legacyPackages.${system};
		in {
			packages.${system} = {
				radiod = pkgs.callPackage ./default.nix {};
				default = self.packages.${system}.radiod;
			};
		};
}
