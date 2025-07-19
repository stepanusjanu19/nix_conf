{ pkgs ? import <nixpkgs> {} }:

let
  bsdtarBin = "${pkgs.libarchive}/bin/bsdtar";
  unarBin = "${pkgs.unar}/bin/unar";
  p7zBin = "${pkgs.p7zip}/bin/7z";

  icon = pkgs.fetchurl {
    url = "https://img.icons8.com/fluency/256/archive-folder.png";
    sha256 = "iX0rMEBT1y44ltHAWg7jnIWNpU/d+XMwtLHiZJ/Jjp8=";
  };

  electron = pkgs.electron;
in

pkgs.stdenv.mkDerivation {
  pname = "UniversalArchiveExtractor";
  version = "1.0.0";

  buildInputs = [ pkgs.makeWrapper pkgs.nodejs electron ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications/Extractor.app/Contents/{MacOS,Resources}
    APPDIR=$out/Applications/Extractor.app/Contents/MacOS

    # Copy icon
    cp ${icon} $out/Applications/Extractor.app/Contents/Resources/icon.png

    # Create main.js
    cat > $APPDIR/main.js <<EOF
const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

function createWindow() {
  const win = new BrowserWindow({
    width: 400,
    height: 300,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  win.loadFile(path.join(__dirname, 'index.html'));

  ipcMain.handle('select-file', async () => {
    const result = await dialog.showOpenDialog(win, {
      properties: ['openFile'],
      filters: [{ name: 'Archives', extensions: ['rar','zip','7z','tar','gz','bz2','xz','iso'] }]
    });
    return result.canceled ? null : result.filePaths[0];
  });

  ipcMain.on('extract-file', (event, filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    const outputDir = path.join(path.dirname(filePath), path.basename(filePath, ext));
    fs.mkdirSync(outputDir, { recursive: true });

    let cmd;
    if (['.rar'].includes(ext)) {
      cmd = "${unarBin} \"" + filePath + "\" -o \"" + outputDir + "\"";
    } else if (['.zip', '.tar', '.gz', '.bz2', '.xz', '.tgz', '.tar.gz', '.tar.xz', '.tar.bz2', '.iso'].includes(ext)) {
      cmd = "${bsdtarBin} -xf \"" + filePath + "\" -C \"" + outputDir + "\"";
    } else if (['.7z'].includes(ext)) {
      cmd = "${p7zBin} x -o\"" + outputDir + "\" \"" + filePath + "\"";
    } else {
      event.reply('extract-result', { error: 'Unsupported file format: ' + ext });
      return;
    }

    exec(cmd, (err, stdout, stderr) => {
      if (err) {
        event.reply('extract-result', { error: stderr || stdout });
      } else {
        event.reply('extract-result', { success: true, message: 'Extraction complete!' });
      }
    });
  });
}

app.whenReady().then(createWindow);
EOF

    # index.html UI
    cat > $APPDIR/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Extractor</title>
  <style>
    body { font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; }
    #status { margin-top: 20px; color: #555; }
    button { padding: 10px 20px; font-size: 16px; }
  </style>
</head>
<body>
  <h1>Universal Extractor</h1>
  <button id="select">Select Archive</button>
  <div id="status"></div>

  <script>
    const { ipcRenderer } = require('electron');

    document.getElementById('select').addEventListener('click', async () => {
      const file = await ipcRenderer.invoke('select-file');
      const status = document.getElementById('status');

      if (!file) {
        status.textContent = 'No file selected.';
        return;
      }

      status.textContent = 'Extracting... Please wait.';
      ipcRenderer.send('extract-file', file);
    });

    ipcRenderer.on('extract-result', (event, result) => {
      const status = document.getElementById('status');
      if (result.error) {
        status.textContent = '❌ ' + result.error;
      } else {
        status.textContent = '✅ ' + result.message;
      }
    });
  </script>
</body>
</html>
EOF

    # Minimal package.json
    cat > $APPDIR/package.json <<EOF
{
  "name": "universal-archive-extractor",
  "version": "1.0.0",
  "main": "main.js"
}
EOF

    # Wrap with Electron
    makeWrapper ${electron}/bin/electron $APPDIR/Extractor --add-flags $APPDIR
    chmod +x $APPDIR/Extractor

    # macOS Info.plist
    cat > $out/Applications/Extractor.app/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Extractor</string>
  <key>CFBundleExecutable</key>
  <string>Extractor</string>
  <key>CFBundleIdentifier</key>
  <string>org.extractor.universal</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>icon.png</string>
</dict>
</plist>
EOF
  '';

  meta = with pkgs.lib; {
    description = "Universal archive extractor with UI using Electron and Nix";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = [ maintainers.yourName ]; # Optional
  };
}

