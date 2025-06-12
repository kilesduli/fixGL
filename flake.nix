{
  description = "A wrapper tool for nix OpenGL applications by using system lib";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = flake-utils.lib.system;
    in
    (flake-utils.lib.eachSystem [ systems.x86_64-linux systems.aarch64-linux ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
          fixGLPackages = import ./fixGL.nix { inherit pkgs lib; };
          packages = (builtins.mapAttrs (_: value: pkgs.callPackage value { }) fixGLPackages);
        in {
          inherit packages;
        }
      )) // rec {
        overlay = overlays.default;
        overlays.default = final: _:
          let
            fixGLPackages = import ./fixGL.nix { pkgs = final; lib = final.lib; };
          in
          (builtins.mapAttrs (_: value: final.callPackage value { }) fixGLPackages);
      };
}
