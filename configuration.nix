{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 1. Habilitar o NUR (Nix User Repository)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Configurações do Nix e Caches
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  # Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  # Bootloader e LUKS
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-3342c12e-259e-45d5-8592-dbba43ae755e".device = "/dev/disk/by-uuid/3342c12e-259e-45d5-8592-dbba43ae755e";
  
  # Suporte a FUSE (essencial para AppImage)
  boot.kernelModules = [ "fuse" ];
  programs.fuse.userAllowOther = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Bahia";
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  console.keyMap = "br-abnt2";

  # Interface KDE Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "br"; variant = ""; };

  # Som (Pipewire) e Impressora
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Usuário e Shell
  users.users.davi = {
    isNormalUser = true;
    description = "davi miguel";
    extraGroups = [ "networkmanager" "wheel" "video" "podman" ];
    shell = pkgs.zsh; 
    packages = with pkgs; [ kdePackages.kate ];
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "history-substring-search" ];
    };
    interactiveShellInit = ''
      fastfetch
      eval "$(zoxide init zsh)"
    '';
  };

  # Virtualização e Apps
  services.flatpak.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    ghostty
    git
    unzip
    curl
    owofetch
    bat
    broot
    btop
    chafa
    duf
    dust
    eza
    fd
    ffmpeg
    fzf
    htop
    perl
    perlPackages.ImageExifTool
    rename
    procs
    rclone
    ripgrep
    rsync
    scrot
    sqlite
    tldr
    tmux
    vnstat
    wget
    xdg-user-dirs
    xsel
    yt-dlp
    zoxide
    wine
    cmatrix
    figlet
    sl
    cowsay
    appimage-run
    fuse
    fuse3
    ifuse
    tor-browser
    kdePackages.kleopatra
    hblock
    keepassxc
    macchanger
    kde-rounded-corners
    gotop ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  system.stateVersion = "25.11";
}
