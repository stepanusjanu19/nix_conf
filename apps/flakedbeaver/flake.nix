{
  description = "Build a macOS .app bundle for DBeaver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        dbeaver = pkgs.dbeaver-bin;

        dbeaverApp = pkgs.stdenv.mkDerivation {
          pname = "DBeaver";
          version = "23.3"; # or whatever version nixpkgs has

          buildInputs = [ pkgs.makeWrapper ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/Applications/DBeaver.app/Contents/MacOS
            mkdir -p $out/Applications/DBeaver.app/Contents/Resources

            # Launcher script
            makeWrapper ${dbeaver}/bin/dbeaver $out/Applications/DBeaver.app/Contents/MacOS/DBeaver

            cp ${./icons/dbeaver.icns} $out/Applications/DBeaver.app/Contents/Resources/dbeaver.icns

            # Optional: minimal Info.plist for macOS
            cat > $out/Applications/DBeaver.app/Contents/Info.plist <<EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
                "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
                <dict>
                <key>CFBundleName</key>
                <string>DBeaver</string>
                <key>CFBundleExecutable</key>
                <string>DBeaver</string>
                <key>CFBundleIdentifier</key>
                <string>org.dbeaver.app</string>
                <key>CFBundleVersion</key>
                <string>${dbeaver.version}</string>
                <key>CFBundlePackageType</key>
                <string>APPL</string>
                <key>CFBundleIconFile</key>
                <string>dbeaver.icns</string>
                </dict>
            </plist>
            EOF
          '';
        };
      in {
        packages.default = dbeaverApp;
      });
}
