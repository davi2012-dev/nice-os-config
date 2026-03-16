{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # --- CONFIGURAÇÃO DO PLYMOUTH (BOOT ANIMADO) ---
  boot.plymouth = {
    enable = true;
    theme = "breeze"; # Tema oficial do KDE
  };
  # Parâmetros para um boot silencioso e limpo
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "loglevel=3" "udev.log_priority=3" ];

  # --- HOME MANAGER CONFIG ---
  home-manager.users.davi = import ./home.nix;
  # ESSA LINHA RESOLVE O ERRO DO .zshrc (Cria um backup automático)
  home-manager.backupFileExtension = "backup"; 

  # --- RESTO DO SEU SISTEMA ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-3342c12e-259e-45d5-8592-dbba43ae755e".device = "/dev/disk/by-uuid/3342c12e-259e-45d5-8592-dbba43ae755e";
  
  boot.kernelModules = [ "fuse" ];
  programs.fuse.userAllowOther = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Bahia";
  i18n.defaultLocale = "pt_BR.UTF-8";

  # ... (suas i18n.extraLocaleSettings e console.keyMap continuam iguais)

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "br"; variant = ""; };

  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.davi = {
    isNormalUser = true;
    description = "davi miguel";
    extraGroups = [ "networkmanager" "wheel" "video" "podman" ];
    shell = pkgs.zsh; 
    packages = with pkgs; [ kdePackages.kate ];
  };

  # Mantive o Zsh aqui, mas você já pode pensar em mover isso para o home.nix depois!
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

  services.flatpak.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    fastfetch ghostty git unzip curl owofetch bat broot btop chafa duf dust eza fd ffmpeg fzf htop 
    perl perlPackages.ImageExifTool rename procs rclone ripgrep rsync scrot sqlite tldr tmux vnstat 
    wget xdg-user-dirs xsel yt-dlp zoxide wine cmatrix figlet sl cowsay appimage-run fuse fuse3 ifuse 
    tor-browser kdePackages.kleopatra hblock keepassxc macchanger kde-rounded-corners gotop
  ];
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  system.stateVersion = "25.11";
}