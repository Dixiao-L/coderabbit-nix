{
  description = "Nix package for CodeRabbit CLI - AI-powered code review tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        coderabbit = final.callPackage ./package.nix { };
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          default = pkgs.coderabbit;
          coderabbit = pkgs.coderabbit;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.coderabbit}/bin/coderabbit";
          };
          coderabbit = {
            type = "app";
            program = "${pkgs.coderabbit}/bin/coderabbit";
          };
          cr = {
            type = "app";
            program = "${pkgs.coderabbit}/bin/cr";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coderabbit
            nixpkgs-fmt
          ];
        };
      }
    ) // {
      overlays.default = overlay;
    };
}
