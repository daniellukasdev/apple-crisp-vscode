{
  pkgs,
  themeSrc,
  version,
}:
pkgs.stdenv.mkDerivation {
  pname = "vscode-theme-deps";
  version = version;

  src = themeSrc;

  nativeBuildInputs = [
    pkgs.nodejs_20
  ];

  # The build phase uses npm to install dependencies
  buildPhase = ''
    npm install --prefix "$src"
  '';

  # The install phase moves the built node_modules to the output path
  installPhase = ''
    mkdir -p $out
    mv "$src/node_modules" $out/
  '';

  # Do not run `npm` on the check phase
  doCheck = false;
}
