{
  inputs = {
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    naersk.url = "github:nix-community/naersk";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    flake-utils,
    naersk,
    rust-overlay,
  }:
    let
      supportedSystems = [
        flake-utils.lib.system.aarch64-darwin
        flake-utils.lib.system.x86_64-darwin
      ];
    in
      flake-utils.lib.eachSystem supportedSystems (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import rust-overlay)
            ];
          };

          craneLib = crane.lib."${system}";

          cargoArtifacts = craneLib.buildDepsOnly {
            src = ./nested;
            nativeBuildInputs = [
              pkgs.libiconv
            ];
          };
        in
          rec {
            packages.foo = craneLib.buildPackage {
              inherit cargoArtifacts;
              pname = "foo";
              postUnpack = ''
                cd $sourceRoot/nested
                sourceRoot="."
              '';
              src = ./.;
              cargoToml = ./nested/Cargo.toml;
              cargoLock = ./nested/Cargo.lock;
              nativeBuildInputs = [
                pkgs.libiconv
              ];
              doCheck = true;
            };

            defaultPackage = packages.foo;

            devShell = pkgs.mkShell {
              RUST_SRC_PATH = pkgs.rust.packages.stable.rustPlatform.rustLibSrc;
              inputsFrom = builtins.attrValues packages;
              nativeBuildInputs = pkgs.lib.foldl
                (state: drv: builtins.concatLists [state drv.nativeBuildInputs])
                []
                (pkgs.lib.attrValues packages)
              ;
            };
          }
      );
}
