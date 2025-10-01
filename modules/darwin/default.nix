{pkgs, ...}: {
  # Ensure Homebrew-installed Zsh is used

  environment = {
    shells = with pkgs; [bash zsh];
    systemPackages = [
      pkgs.coreutils
    ];
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
  };

  # Enable Homebrew services (like zsh completion)
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {};
    casks = ["raycast" "amethyst"];
    taps = ["fujiapple852/trippy"];
    brews = [];
  };

  nix = {
    enable = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.zsh.enable = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = false; # Keep Caps Lock normal
    };

    activationScripts.ensureRunDir.text = ''
      mkdir -p /run
      chown ${builtins.getEnv "USER"} /run
    '';

    defaults = {
      finder.AppleShowAllExtensions = true;
      finder._FXShowPosixPathInTitle = true;
      dock.autohide = true;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.InitialKeyRepeat = 14;
      NSGlobalDomain.KeyRepeat = 1;
    };

    stateVersion = 4;
  };

  ids.gids.nixbld = 350;

  # Fonts
  # fonts.fontDir.enable = true; # DANGER
  # fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; }) ];
}
