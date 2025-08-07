{
  description = "Build a macOS .app bundle for Balena Etcher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    etcher-pkgs.url = "github:NixOS/nixpkgs/46d7d71026409f4a1d134fd0df3aa803aef2d061";
  };


  outputs = { self, nixpkgs, flake-utils, etcher-pkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        etcherPkgs = import etcher-pkgs { inherit system; };

        etcher = etcherPkgs.balena-etcher;

        etcherApp = pkgs.stdenv.mkDerivation {
          pname = "balenaEtcher";
          version = etcher.version;

          buildInputs = [ pkgs.makeWrapper ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/Applications/balenaEtcher.app/Contents/MacOS
            mkdir -p $out/Applications/balenaEtcher.app/Contents/Resources

            makeWrapper ${etcher}/bin/balena-etcher $out/Applications/balenaEtcher.app/Contents/MacOS/Etcher

            cp ${./icons/etcher.icns} $out/Applications/balenaEtcher.app/Contents/Resources/etcher.icns

            cat > $out/Applications/balenaEtcher.app/Contents/Info.plist <<EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
              "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
              <dict>
                <key>CFBundleName</key>
                <string>balenaEtcher</string>
                <key>CFBundleExecutable</key>
                <string>balenaEtcher</string>
                <key>CFBundleIdentifier</key>
                <string>io.balena.etcher</string>
                <key>CFBundleVersion</key>
                <string>${etcher.version}</string>
                <key>CFBundlePackageType</key>
                <string>APPL</string>
                <key>CFBundleIconFile</key>
                <string>etcher.icns</string>
              </dict>
            </plist>
            EOF
          '';
        };
      in {
        packages.default = etcherApp;
      });
}
