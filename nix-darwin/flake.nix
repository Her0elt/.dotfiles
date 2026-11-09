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

  outputs = inputs@{ self, nix-darwin, nixpkgs, ... }:
  let
    configuration = { pkgs, config, ... }:
    let
      # .NET 9 + 10 SDKs in one root. Bump with `nix flake update nixpkgs`.
      dotnet = pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_9_0-bin
        pkgs.dotnetCorePackages.sdk_10_0-bin
      ];
    in {
      # List packages installed in system profile. To search by name, run:
      environment.variables = {
            EDITOR = "nvim";
            DOTNET_ROOT = "${dotnet}/share/dotnet";

          };
      environment.systemPackages =
        [
          pkgs.pnpm
          pkgs.tree-sitter # nvim-treesitter (main) compiles parsers with this
          pkgs.fzf
          pkgs.fd
          pkgs.go
          pkgs.git
          pkgs.wget
          pkgs.tmux
          pkgs.docker
          pkgs.openjdk
          dotnet
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

          # --- moved from homebrew ---
          pkgs.ansible
          pkgs.azure-cli
          pkgs.cocoapods
          pkgs.coreutils-prefixed # g-prefixed (gls, gdate...) like brew; don't shadow BSD tools
          pkgs.clang-tools # clangd/clang-format (brew llvm was keg-only)
          pkgs.docker-compose
          pkgs.fnm
          pkgs.gh
          pkgs.gleam
          pkgs.erlang # gleam's BEAM runtime
          pkgs.maestro
          pkgs.pulumi-bin
          pkgs.redpanda-client # rpk
          pkgs.consul
          pkgs.nomad
          pkgs.vault
          pkgs.mongodb-tools
          pkgs.zoxide # tmux-sessionx zoxide-mode
          pkgs.jankyborders # `borders`, started from .aerospace.toml
          pkgs.ngrok
          pkgs.nodejs_24
          pkgs.postgresql_14
          pkgs.pyenv
          pkgs.python312
          pkgs.uv
          # only telnet from inetutils (full pkg would shadow ping/ifconfig/hostname)
          (pkgs.runCommand "telnet" { } ''
            mkdir -p $out/bin
            ln -s ${pkgs.inetutils}/bin/telnet $out/bin/telnet
          '')
        ];

      fonts.packages = with pkgs.nerd-fonts; [
        caskaydia-cove
        hack
        jetbrains-mono
        meslo-lg
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
      # system.activationScripts.postUserActivation.text = ''
      #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      # '';

      users.users.hermannelton.home = "/Users/hermannelton";
      # home-manager.backupFileExtension = "backup";
      # nix.configureBuildUsers = true;
      # nix.useDaemon = true;
      system.primaryUser="hermannelton";
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
      # Homebrew tap trust (https://docs.brew.sh/Tap-Trust). Merged into both trust
      # files before `brew bundle` runs: ~/.config/homebrew (interactive, XDG set)
      # and ~/.homebrew (activation's sudo drops XDG_CONFIG_HOME).
      system.activationScripts.extraActivation.text =
        let
          user = config.system.primaryUser;
          home = config.users.users.${user}.home;
          trust = pkgs.writeText "brew-trust.json" (builtins.toJSON {
            trustedformulae = [
              "azure/functions/azure-functions-core-tools"
              "azure/functions/azure-functions-core-tools@4"
              "microsoft/mssql-release/msodbcsql18"
              "microsoft/mssql-release/mssql-tools18"
              "blankoslo/tools/tim"
            ];
            trustedcasks = [
              "confluentinc/confluent-hub-client/confluent-hub-client"
            ];
          });
        in ''
          echo "merging homebrew tap trust..." >&2
          for f in "${home}/.homebrew/trust.json" "${home}/.config/homebrew/trust.json"; do
            mkdir -p "$(dirname "$f")"
            [ -s "$f" ] || echo '{}' > "$f"
            ${pkgs.jq}/bin/jq -s 'reduce .[] as $o ({}; reduce ($o | to_entries[]) as $e (.; .[$e.key] = ((.[$e.key] // []) + $e.value | unique)))' \
              "$f" ${trust} > "$f.tmp" && mv "$f.tmp" "$f"
            chown -R ${user}:staff "$(dirname "$f")"
            chmod 600 "$f"
          done
        '';

      homebrew.enable = true;
      # msodbcsql18/mssql-tools18 block on an interactive EULA prompt during `brew bundle`
      environment.etc."homebrew/brew.env".text = ''
        HOMEBREW_ACCEPT_EULA=Y
      '';
      homebrew.onActivation.upgrade = true;
      homebrew.taps = [
          "confluentinc/confluent-hub-client"
          "microsoft/mssql-release"
          "blankoslo/tools"
          "azure/functions"
      ];
      # GUI apps stay as casks: nix .apps break self-updaters/Spotlight.
      homebrew.onActivation.cleanup = "uninstall";
      homebrew.casks = [
          "ghostty"
          "hyperkey"
          "docker-desktop"
          "google-chrome"
          "iterm2"
          "slack"
          "r-app"
          "rstudio"
          "zulu@17" # registers in /Library/Java (java_home), nix JDKs don't
          "android-commandlinetools"
          "confluent-hub-client"
      ];
      # Not available in nixpkgs
      homebrew.brews = [
          "ghcup"
          "docker-machine"
          "nvm"
          "python@3.9"
          "go-parquet-tools"
          "zlib" # headers for pyenv python builds
          "microsoft/mssql-release/msodbcsql18" # no nix ODBC driver on darwin
          "microsoft/mssql-release/mssql-tools18" # sqlcmd + bcp
          "blankoslo/tools/tim"
          "azure/functions/azure-functions-core-tools@4" # nix pkg source-builds .NET
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

