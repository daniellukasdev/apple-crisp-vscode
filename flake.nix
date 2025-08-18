{
  description = "A color theme for Visual Studio Code that uses colors from Apple color guidelines.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs}: let
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        apple-crisp-vscode = pkgs.callPackage pkgs.stdenv.mkDerivation {
          pname = "apple-crisp-vscode";
          version = "0.0.1";

          src = ./.;

          buildInputs = [pkgs.nodejs]; # Required for vsce
          nativeBuildInputs = [pkgs.vsce]; # VS Code Extension manager

          installPhase = ''
            vsce package
            mkdir -p $out/share/vscode/extensions/apple-crisp-vscode
            cp *.vsix $out/share/vscode/extensions/apple-crisp-vscode
          '';
        };
      }
    );
  };
}
