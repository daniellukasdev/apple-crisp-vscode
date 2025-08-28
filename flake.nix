{
  description = "A Nix flake to build Apple Crisp Visual Studio Code theme from a git repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      packageJSON = builtins.fromJSON (builtins.readFile ./package.json);

      # The theme's name and publisher, used by `vsce` for the build
      themeName = packageJSON.name;
      # publisher = "my-publisher";
      inherit
        (packageJSON)
        # publisher
        version
        ;

      # The Git URL and revision of the theme's source repository
      # themeSrc = pkgs.fetchFromGitHub {
      #   owner = publisher;
      #   repo = themeName;
      #   rev = "06d1764d144dd1e57988248e5e0023d8b306c0e0";
      #   hash = "sha256-zycMRWlOJu3LOYShI+Zw+XEMTVxAiUcg7Gdv+L045d0=";
      # };

      themeSrc = builtins.fetchGit {
        name = themeName;
        url = "https://github.com/daniellukasdev/apple-crisp-vscode.git";
        ref = "main";
        # rev = "06d1764d144dd1e57988248e5e0023d8b306c0e0";
        # hash = pkgs.lib.fakeSha256;
      };

      nodeDependencies = pkgs.callPackage ./node-dependencies.nix {
        inherit themeSrc;
        inherit version;
      };
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "${themeName}-vsix";
        version = version; # The version is specified in the theme's package.json
        src = themeSrc;

        nativeBuildInputs = [
          pkgs.vsce
          pkgs.nodejs_20
        ];

        # We provide the node_modules as input to `vsce` via the `nodeDependencies` package
        buildInputs = [nodeDependencies];

        # VSCE requires the theme's dependencies to be in the `node_modules` directory
        installPhase = ''
          # Create a symbolic link to the pre-built node_modules directory
          ln -s ${nodeDependencies}/node_modules "$src/node_modules"

          # Package the extension with vsce
          vsce package --out ${themeName}.vsix

          # Move the output vsix file to the final destination
          mkdir -p $out
          mv ${themeName}.vsix $out/
        '';
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.vsce
          pkgs.nodejs_20 # Explicitly include nodejs to provide npm
        ];
      };
    });
}
