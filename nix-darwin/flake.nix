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
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      environment.variables = { EDITOR = "nvim";};
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
          pkgs.nodejs
          pkgs.openjdk
          pkgs.dotnet-sdk_9
          pkgs.ripgrep
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

      users.users.hermannelton.home = "/Users/hermannelton";
      # home-manager.backupFileExtension = "backup";
      # nix.configureBuildUsers = true;
      # nix.useDaemon = true;

      system.defaults = {
        NSGlobalDomain.AppleShowScrollBars = "Automatic";
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllFiles = true;
        finder.ShowStatusBar = true;
        finder.ShowPathbar = true;
        finder.QuitMenuItem = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "Hermann Elton";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.onActivation.upgrade = true;
      homebrew.casks = [
          "ghostty"
          "hyperkey"
      ];
      homebrew.brews = [
          "postgresql@14"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
          "zsh-completions"
          "docker-machine"
          "nvm"
          "python@3.9"
          "gleam"
          "docker-compose"
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

