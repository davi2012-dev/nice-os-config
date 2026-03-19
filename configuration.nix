{ config, pkgs, ... }:

let
  # Definindo o painel aqui fora para ser acessível em todo o arquivo
  painel-gabinete = pkgs.writers.writePython3Bin "painel-gabinete" {
    libraries = with pkgs.python3Packages; [ pyside6 psutil ];
  } ''
    import sys, psutil
    from PySide6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLabel, QProgressBar
    from PySide6.QtCore import QTimer, Qt

    class Dashboard(QWidget):
        def __init__(self):
            super().__init__()
            self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
            self.setStyleSheet("background-color: black; color: #00ff00; font-family: 'Roboto Mono';")
            self.setFixedSize(320, 480)
            layout = QVBoxLayout()
            self.cpu_bar = QProgressBar(); self.ram_bar = QProgressBar()
            style = "QProgressBar { border: 1px solid #333; border-radius: 5px; text-align: center; background: #111; } QProgressBar::chunk { background-color: #00ff00; }"
            self.cpu_bar.setStyleSheet(style); self.ram_bar.setStyleSheet(style.replace("#00ff00", "#00ccff"))
            layout.addWidget(QLabel("CPU USAGE")); layout.addWidget(self.cpu_bar)
            layout.addWidget(QLabel("RAM USAGE")); layout.addWidget(self.ram_bar)
            self.setLayout(layout)
            timer = QTimer(self); timer.timeout.connect(self.update_stats); timer.start(1000)

        def update_stats(self):
            self.cpu_bar.setValue(int(psutil.cpu_percent()))
            self.ram_bar.setValue(int(psutil.virtual_memory().percent))

    app = QApplication(sys.argv)
    win = Dashboard(); win.show(); sys.exit(app.exec())
  '';

  nix-sync = pkgs.writeShellScriptBin "nix-sync" ''
    echo "Atualizando canais..."
    sudo nix-channel --update
    echo "Reconstruindo sistema..."
    sudo nixos-rebuild switch --upgrade
    echo "Limpando gerações antigas..."
    sudo nix-collect-garbage -d
    echo "Backup Git..."
    cd /etc/nixos && sudo git add . && sudo git commit -m "Auto: $(date)" && sudo git push
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # --- BOOT E LIMITE DE GERAÇÕES ---
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- PLYMOUTH (BOOT ANIMADO) ---
  boot.plymouth = {
    enable = true;
    theme = "bgrt"; 
  };
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "loglevel=3" "udev.log_priority=3" ];

  # --- HOME MANAGER ---
  home-manager.users.davi = import ./home.nix;
  home-manager.backupFileExtension = "backup"; 

  # --- CONFIGURAÇÕES DO NIX E LIMPEZA ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- SISTEMA E HARDWARE ---
  nixpkgs.config.allowUnfree = true;

  boot.initrd.luks.devices."luks-3342c12e-259e-45d5-8592-dbba43ae755e".device = "/dev/disk/by-uuid/3342c12e-259e-45d5-8592-dbba43ae755e";
  boot.kernelModules = [ "fuse" ];
  programs.fuse.userAllowOther = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ]; 
  time.timeZone = "America/Bahia";
  i18n.defaultLocale = "pt_BR.UTF-8";

  # --- INTERFACE (KDE PLASMA 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "br"; variant = ""; };

  # Bluetooth e KDE Connect
  hardware.bluetooth.enable = true;
  programs.kdeconnect.enable = true;

  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USUÁRIO ---
  users.users.davi = {
    isNormalUser = true;
    description = "davi miguel";
    extraGroups = [ "networkmanager" "wheel" "video" "podman" "bluetooth" ];
    shell = pkgs.zsh; 
    packages = with pkgs; [ kdePackages.kate ];
  };

  # --- ZSH E POWERLEVEL10K ---
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.ztheme";
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "history-substring-search" ];
    };
    interactiveShellInit = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      fastfetch
      eval "$(zoxide init zsh)"
    '';
  };

  # --- VARIÁVEIS DE AMBIENTE ---
  environment.variables = {
    QML2_IMPORT_PATH = [
      "${pkgs.kdePackages.qtwebsockets}/lib/qt-6/qml"
      "${pkgs.kdePackages.qtconnectivity}/lib/qt-6/qml"
      "${pkgs.kdePackages.kdeconnect-kde}/lib/qt-6/qml"
      "${pkgs.kdePackages.bluez-qt}/lib/qt-6/qml"
      "${pkgs.kdePackages.qtmultimedia}/lib/qt-6/qml"
      "${pkgs.kdePackages.plasma-nm}/lib/qt-6/qml"
      "${pkgs.kdePackages.bluedevil}/lib/qt-6/qml"
    ];
  };

  # --- PACOTES ---
  environment.systemPackages = with pkgs; [
    nix-sync painel-gabinete pkg-config libevdev fastfetch ghostty git unzip curl owofetch bat broot btop chafa 
    duf dust eza fd ffmpeg fzf htop perl perlPackages.ImageExifTool rename procs rclone 
    ripgrep rsync scrot sqlite tldr tmux vnstat wget xdg-user-dirs xsel yt-dlp zoxide 
    wine cmatrix figlet sl cowsay appimage-run fuse fuse3 ifuse tor-browser 
    kdePackages.kleopatra hblock keepassxc macchanger kde-rounded-corners gotop cava
    kdePackages.qtwebsockets kdePackages.qtconnectivity kdePackages.qtmultimedia
    kdePackages.kdeconnect-kde kdePackages.bluez-qt kdePackages.bluedevil kdePackages.plasma-nm
    lzip distrobox ryubing roboto roboto-mono
  ];

  # --- SERVIÇO AUTO-START PAINEL ---
  systemd.user.services.painel-touch = {
    description = "Inicia painel touch";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${painel-gabinete}/bin/painel-gabinete";
  };

  # --- CONFIGURAÇÃO WAYDROID E GPU AMD ---
  services.flatpak.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.waydroid.enable = true;

  systemd.services.waydroid-gpu-persistence = {
    description = "Forçar propriedades da GPU AMD para Waydroid";
    after = [ "waydroid-container.service" ];
    bindsTo = [ "waydroid-container.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "waydroid-amd-fix" ''
        set -e
        ${pkgs.coreutils}/bin/sleep 2
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.gralloc gbm
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.egl mesa
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set gralloc.gbm.device /dev/dri/renderD129
      ''}";
      RemainAfterExit = true;
    };
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  system.stateVersion = "25.11";
}