{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:vkleen/nixpkgs/master";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, ... }: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import inputs.rust-overlay) ];
      pkgs = import inputs.nixpkgs { inherit system overlays; };
    in with pkgs; {
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
