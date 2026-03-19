{ config, pkgs, ... }:

let
  painel-gabinete = pkgs.rustPlatform.buildRustPackage rec {
    pname = "painel-gabinete";
    version = "1.0.0";

    src = pkgs.writeTextDir "src/main.rs" ''
      use sysinfo::{CpuExt, System, SystemExt};
      use std::thread;
      use std::time::Duration;

      fn main() {
          let mut sys = System::new_all();
          loop {
              sys.refresh_all();
              let cpu = sys.global_cpu_info().cpu_usage();
              let ram = (sys.used_memory() as f32 / sys.total_memory() as f32) * 100.0;
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
    
    # O Nix vai falhar aqui e te dar o hash real. Substitua quando ele avisar.
    cargoHash = pkgs.lib.fakeHash; 
  };

  nix-sync = pkgs.writeShellScriptBin "nix-sync" ''
    sudo nixos-rebuild switch --upgrade && \
    cd /etc/nixos && sudo git add . && sudo git commit -m "Auto: $(date)" && sudo git push
  '';
in
{
  imports = [ ./hardware-configuration.nix <home-manager/nixos> ];

  # --- FIX DO ZSH ---
  programs.zsh.enable = true; # ESSENCIAL: Resolve o erro do seu log

  # --- RESTO DA CONFIGURAÇÃO ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

  users.users.davi = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "podman" "bluetooth" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    nix-sync painel-gabinete git fastfetch btop rustc cargo gcc
  ];

  # --- WAYDROID GPU AMD ---
  virtualisation.waydroid.enable = true;
  systemd.services.waydroid-gpu-fix = {
    description = "Configura GPU AMD no Waydroid";
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