{ config, pkgs, ... }:

let
  # Painel em Rust: Performance máxima e sem erros de linter de script
  painel-gabinete = pkgs.rustPlatform.buildRustPackage rec {
    pname = "painel-gabinete";
    version = "1.0.0";

    src = pkgs.writeTextDir "src/main.rs" ''
      use sysinfo::{CpuExt, System, SystemExt};
      use std::thread;
      use std::time::Duration;

      fn main() {
          let mut sys = System::new_all();
          println!("Monitor de Sistema iniciado.");
          loop {
              sys.refresh_all();
              let cpu = sys.global_cpu_info().cpu_usage();
              let ram = (sys.used_memory() as f32 / sys.total_memory() as f32) * 100.0;
              
              // Saída formatada (Pode ser visualizada via journalctl -u painel-touch)
              println!("CPU: {:.1}% | RAM: {:.1}%", cpu, ram);
              thread::sleep(Duration::from_secs(1));
          }
      }
    '';

    cargoConfig = pkgs.writeText "Cargo.toml" ''
      [package]
      name = "painel-gabinete"
      version = "1.0.0"
      edition = "2021"

      [dependencies]
      sysinfo = "0.29"
    '';

    unpackPhase = "mkdir -p src && cp $src/src/main.rs src/ && cp $cargoConfig Cargo.toml";
    
    # IMPORTANTE: No primeiro build, o Nix vai dar erro de hash. 
    # Copie o hash correto do erro e cole aqui.
    cargoHash = pkgs.lib.fakeHash; 
  };

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

  # --- BOOT & KERNEL ---
  boot.loader.systemd-boot = { enable = true; configurationLimit = 5; };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "loglevel=3" "udev.log_priority=3" ];

  # --- SISTEMA ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ]; 
  time.timeZone = "America/Bahia";
  i18n.defaultLocale = "pt_BR.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # --- INTERFACE (PLASMA 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };

  # --- USUÁRIO ---
  users.users.davi = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "podman" "bluetooth" ];
    shell = pkgs.zsh;
  };

  # --- PACOTES ---
  environment.systemPackages = with pkgs; [
    nix-sync painel-gabinete git fastfetch btop ghostty 
    rustc cargo gcc distrobox lzip
  ] ++ (with pkgs.kdePackages; [ kdeconnect-kde kate ]);

  # --- SERVIÇOS ---
  systemd.user.services.painel-touch = {
    description = "Painel de Monitoramento (Rust)";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${painel-gabinete}/bin/painel-gabinete";
  };

  # --- WAYDROID + GPU AMD ---
  virtualisation.waydroid.enable = true;
  virtualisation.podman.enable = true;

  systemd.services.waydroid-gpu-fix = {
    description = "Configura GPU AMD (Mesa/GBM) no Waydroid";
    after = [ "waydroid-container.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "waydroid-fix" ''
        ${pkgs.coreutils}/bin/sleep 5
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.gralloc gbm
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set ro.hardware.egl mesa
        ${config.virtualisation.waydroid.package}/bin/waydroid prop set gralloc.gbm.device /dev/dri/renderD129
      ''}";
    };
    wantedBy = [ "multi-user.target" ];
  };

  system.stateVersion = "25.11";
}