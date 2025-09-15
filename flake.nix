{
  description = "A Nix flake to build Apple Crisp Visual Studio Code theme from a git repository";

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
      # packageName = "${themeName}-${themeVersion}";
      description = packageJson.description;

      theme-vsix = pkgs.stdenv.mkDerivation {
        pname = "${themeName}-vsix";
        version = themeVersion;
        src = ./.;

        buildInputs = with pkgs; [nodejs vsce];

        preInstallPhase = ''${packageJson.scripts.preinstall}'';

        buildPhase = ''vsce package'';

        installPhase = ''
          mkdir -p $out/share/vscode/extensions
          mv ${themeName}-${themeVersion}.vsix $out/share/vscode/extensions/
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
        shellHook = ''
          echo "Run 'npm install' or 'nix-shell --command \"npm install\"' if you need node_modules."
        '';
      };
    });
}
