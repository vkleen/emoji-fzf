{
  description = "Generate emoji input for fzf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, ... }: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      name = "emoji-fzf";

      overlays =
        [ (import inputs.rust-overlay) ];
      pkgs = import inputs.nixpkgs { inherit system overlays; };

      rust = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.minimal.override {
        extensions = [ "rust-src" "rust-analysis" "rustfmt" "clippy" ];
        targets = [ (pkgs.rust.toRustTarget pkgs.stdenv.hostPlatform) ];
      });

      craneLib = inputs.crane.lib.${system}.overrideToolchain rust;

      emoji-fzf = craneLib.buildPackage {
        src = pkgs.lib.cleanSourceWith {
          src = pkgs.lib.cleanSource (craneLib.path ./.);
          filter = path: type: builtins.any (filter: filter path type) [
            craneLib.filterCargoSources
            (path: _type: builtins.match ".*/gemoji/db/emoji\.json$" path != null)
          ];
        };
      };
    in rec {
      packages.${name} = emoji-fzf;
      defaultPackage = packages.${name};
    });
}
