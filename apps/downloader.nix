{ pkgs ? import <nixpkgs> {} }:

let
  aria2c = "${pkgs.aria2}/bin/aria2c";

  # Download AriaNg release with updated hash
  ariaNg = pkgs.fetchzip {
    url = "https://github.com/mayswind/AriaNg/releases/download/1.3.7/AriaNg-1.3.7.zip";
    sha256 = "9YUscIGHHUg2V5fGgBqLw87oFZrwj1frwl4YsIxXzTM=";
    stripRoot = false;
  };

  icon = pkgs.fetchurl {
    url = "https://img.icons8.com/color/256/download.png";
    sha256 = "3y6z17HbKxfOfewauEWvoqP/Me8mSKSay4P2vnjwtu4=";
  };

  electron = pkgs.electron;

in pkgs.stdenv.mkDerivation {
  pname = "Aria2ElectronApp";
  version = "1.0.0";

  buildInputs = [ pkgs.makeWrapper pkgs.nodejs electron ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications/Aria2.app/Contents/{MacOS,Resources}

    # App root
    APPDIR=$out/Applications/Aria2.app/Contents/MacOS

    # Copy icon
    cp ${icon} $out/Applications/Aria2.app/Contents/Resources/Aria2.png

    # Electron main process
    cat > $APPDIR/main.js <<EOF
const { app, BrowserWindow } = require('electron');
const { exec } = require('child_process');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1000,
    height: 700,
    icon: path.join(__dirname, '../Resources/Aria2.png'),
    webPreferences: {
      contextIsolation: true
    }
  });

  win.loadFile(path.join(__dirname, 'AriaNg/index.html'));
}

app.whenReady().then(() => {
  exec("${aria2c} --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all --dir=$HOME/Downloads");
  createWindow();
});
EOF

    # Copy AriaNg UI files
    cp -r ${ariaNg} $APPDIR/AriaNg

    # Create package.json
    cat > $APPDIR/package.json <<EOF
{
  "name": "aria2-electron",
  "version": "1.0.0",
  "main": "main.js"
}
EOF

    # Wrap the Electron launcher
    makeWrapper ${electron}/bin/electron $APPDIR/Aria2 --add-flags $APPDIR

    chmod +x $APPDIR/Aria2

    # Create macOS app Info.plist
    cat > $out/Applications/Aria2.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Aria2</string>
  <key>CFBundleExecutable</key>
  <string>Aria2</string>
  <key>CFBundleIdentifier</key>
  <string>org.aria2.electron</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>Aria2.png</string>
</dict>
</plist>
EOF
  '';

  meta = with pkgs.lib; {
    description = "Aria2 + AriaNg wrapped in an Electron GUI as a macOS .app";
    homepage = "https://aria2.github.io/";
    license = licenses.gpl2;
    platforms = platforms.darwin;
  };
}

