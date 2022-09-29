{
  description = "Generate emoji input for fzf";

  inputs = {
    nixpkgs.url = sourcehut:~vkleen/nixpkgs?host=git.sr.ht.kleen.org;
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {
      url = "github:kolloch/crate2nix";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, ... }: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      name = "emoji-fzf";

      overlays =
        [ (import inputs.rust-overlay)
          (final: prev: {
            rustc = final.rust-bin.nightly.latest.default;
            cargo = final.rust-bin.nightly.latest.default;
          })
        ];
      pkgs = import inputs.nixpkgs { inherit system overlays; };

      inherit (import "${inputs.crate2nix}/tools.nix" { inherit pkgs; })
        generatedCargoNix;
      
      project = import (generatedCargoNix { inherit name; src = ./.; })
                  { inherit pkgs; };
    in with pkgs; rec {
      packages.${name} = project.rootCrate.build;
      defaultPackage = packages.${name};
      
      devShell = mkShell {
        buildInputs = [
          openssl pkgconfig
          (rust-bin.nightly.latest.default.override {
            extensions = [ "rust-src" "rust-analyzer-preview" "llvm-tools-preview" "rustfmt-preview" ];
          })
        ];
      };
    });
}
