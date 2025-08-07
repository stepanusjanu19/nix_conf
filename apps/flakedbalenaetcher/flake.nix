{
  description = "Build a macOS .app bundle for Balena Etcher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        etcher = pkgs.balena-etcher;

        etcherApp = pkgs.stdenv.mkDerivation {
          pname = "balenaEtcher";
          version = etcher.version;

          buildInputs = [ pkgs.makeWrapper ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/Applications/Etcher.app/Contents/MacOS
            mkdir -p $out/Applications/Etcher.app/Contents/Resources

            # Launcher script for the Etcher Electron binary
            makeWrapper ${etcher}/bin/balena-etcher $out/Applications/Etcher.app/Contents/MacOS/Etcher

            # Icon file (you must provide this)
            cp ${./icons/etcher.icns} $out/Applications/Etcher.app/Contents/Resources/etcher.icns

            # Info.plist metadata
            cat > $out/Applications/Etcher.app/Contents/Info.plist <<EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
              "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
              <dict>
                <key>CFBundleName</key>
                <string>Etcher</string>
                <key>CFBundleExecutable</key>
                <string>Etcher</string>
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
