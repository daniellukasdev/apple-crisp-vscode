{
  description = "A Nix flake to build Apple Crisp Visual Studio Code theme.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      packageJson = builtins.fromJSON (builtins.readFile ./package.json);
      themeName = packageJson.name;
      themeVersion = packageJson.version;
      description = packageJson.description;

      vsixFilename = "${themeName}-${themeVersion}.vsix";

      theme-vsix = pkgs.stdenv.mkDerivation {
        pname = "${themeName}-vsix";
        version = themeVersion;
        src = ./.;

        buildInputs = with pkgs; [nodejs vsce];

        buildPhase = ''
          vsce package --out ${vsixFilename}
        '';

        installPhase = ''
          mkdir -p $out
          mv ${vsixFilename} $out/
        '';

        meta = {
          description = "VSCode extension: ${description}";
          homepage = packageJson.homepage;
          license = pkgs.lib.licenses.mit;
        };
      };
    in {
      packages.default = theme-vsix;
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs
          pkgs.vsce
          pkgs.git
          pkgs.jq
          pkgs.libsecret
          pkgs.glib
          pkgs.pkg-config
        ];
      };
      # Export the filename for use in other flakes
      lib.vsixFilename = vsixFilename;
    });
}
