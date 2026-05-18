{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs?rev=d2faa1bbca1b1e4962ce7373c5b0879e5b12cef2";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
  let
    configuration = { pkgs, ... }:
    let
      # dotnet9 = pkgs.writeShellScriptBin "dotnet9" ''
      #   exec ${pkgs.dotnet-sdk_9}/bin/dotnet "$@"
      # '';
      # dotnet10 = pkgs.writeShellScriptBin "dotnet10" ''
      #   exec ${pkgs.dotnet-sdk_10}/bin/dotnet "$@"
      # '';
      # dotnetDefault = pkgs.writeShellScriptBin "dotnet" ''
      #   exec ${pkgs.dotnet-sdk_10}/bin/dotnet "$@"
      # '';
      dotnet = pkgs.dotnetCorePackages.dotnet_10.sdk;
      dotnetWrapper = pkgs.writeShellScriptBin "dotnet" ''
            export DOTNET_ROOT="${pkgs.dotnet-sdk_10}/share/dotnet"
            exec "${dotnet}/share/dotnet/dotnet" "$@"
      '';
    in {
      # List packages installed in system profile. To search by name, run:
      environment.variables = {
            EDITOR = "nvim";
            DOTNET_ROOT = "/opt/homebrew/opt/dotnet@10/libexec";

          };
      environment.systemPackages =
        [
          pkgs.pnpm
          pkgs.fzf
          pkgs.fd
          pkgs.go
          pkgs.git
          pkgs.wget
          pkgs.tmux
          pkgs.docker
          pkgs.openjdk
          # dotnetWrapper
          # pkgs.dotnetCorePackages.dotnet_10.sdk

          # dotnet9
          # dotnet10
          # dotnetDefault
          pkgs.ripgrep
          pkgs.just
          pkgs.stack
          #curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
          pkgs.ghc
          pkgs.direnv
          pkgs.sshs
          pkgs.glow
          pkgs.nushell
          pkgs.tableplus
          pkgs.raycast
          pkgs.rustc
          pkgs.podman
          pkgs.cargo
          pkgs.aerospace
          pkgs.stow
          pkgs.carapace
          pkgs.gradle
          pkgs.lazygit
          # pkgs.sketchybar
          # pkgs.sketchybar-app-font
          (pkgs.neovim.override { vimAlias = true; })
        ];
      # services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      security.pam.services.sudo_local.enable = true;
      security.pam.services.sudo_local.touchIdAuth = true;
      system.activationScripts.postUserActivation.text = ''
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

      users.users.hermannelton.home = "/Users/hermannelton";
      # home-manager.backupFileExtension = "backup";
      # nix.configureBuildUsers = true;
      # nix.useDaemon = true;
      system.defaults.CustomUserPreferences = {
        "com.apple.screencapture" = {
          location = "~/screenshots";
          type = "png";
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        # Turn on app auto-update
        "com.apple.commerce".AutoUpdate = true;
      };

      system.defaults = {
        NSGlobalDomain.AppleShowScrollBars = "Automatic";
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        screencapture.location = "~/screenshots";
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllFiles = true;
        finder.ShowStatusBar = true;
        finder.ShowPathbar = true;
        finder.QuitMenuItem = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "Hermann Elton";
        screensaver.askForPasswordDelay = 10;
      };

      # services.sketchybar = {
      #   enable = true;
      #
      #   extraPackages = [
      #     pkgs.jq
      #     pkgs.aerospace
      #   ];
      # };
      homebrew.enable = true;
      homebrew.onActivation.upgrade = true;
      # homebrew.taps = [
      #   "junian/homebrew-dotnet"
      # ];
      homebrew.casks = [
          "ghostty"
          "hyperkey"
      ];
      homebrew.brews = [
          "postgresql@14"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
          "zsh-completions"
          "ghcup"
          # "powershell"
          "docker-machine"
          "nvm"
          "node@24"
          "python@3.9"
          # "dotnet@10"
          "gleam"
          "docker-compose"
          "uv"
      ];
    };
  in
  {
    darwinConfigurations."Hermann-sin-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
	configuration
        # home-manager.darwinModules.home-manager {
        #   home-manager.useGlobalPkgs = true;
        #   home-manager.useUserPackages = true;
        #   home-manager.users.hermannelton = import ./home.nix;
        # }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Hermann-sin-MacBook-Pro".pkgs;
  };
}

