{ pkgs ? import <nixpkgs> {} }:

let
  telegramBinary = "${pkgs.telegram-desktop}/bin/Telegram";
  telegramIconUrl = "https://img.icons8.com/color/256/000000/telegram-app.png";

  telegramIcon = pkgs.fetchurl {
    url = "https://img.icons8.com/color/256/000000/telegram-app.png";
    sha256 = "sha256-G0oSzxcJh8mEVnM/d+pR8U8WeKeh29tRcDivT4be83s=";
  };
in

pkgs.stdenv.mkDerivation {
  pname = "TelegramDesktopApp";
  version = "custom";

  buildInputs = [ pkgs.makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications/Telegram.app/Contents/MacOS
    mkdir -p $out/Applications/Telegram.app/Contents/Resources
    mkdir -p $out/Applications/Telegram.app/Contents

    # Copy telegram binary
    cp ${telegramBinary} $out/Applications/Telegram.app/Contents/MacOS/Telegram

    # Copy the icon PNG
    cp ${telegramIcon} $out/Applications/Telegram.app/Contents/Resources/Telegram.png

    # Optional wrapper with env
    wrapProgram $out/Applications/Telegram.app/Contents/MacOS/Telegram \
      --prefix PATH : ${pkgs.stdenv.cc.cc}/bin

    # Minimal Info.plist
    cat > $out/Applications/Telegram.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Telegram</string>
  <key>CFBundleExecutable</key>
  <string>Telegram</string>
  <key>CFBundleIdentifier</key>
  <string>org.telegram.desktop</string>
  <key>CFBundleVersion</key>
  <string>custom</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>Telegram.png</string>
</dict>
</plist>
EOF
  '';

  meta = with pkgs.lib; {
    description = "Telegram Desktop wrapped as .app bundle for macOS with PNG icon";
    homepage = "https://desktop.telegram.org/";
    license = licenses.gpl3;
    platforms = platforms.darwin;
  };
}

