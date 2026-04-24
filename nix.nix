{ config, pkgs, lib, ... }: {

  # --- 1. Nix Package Manager Elite Config ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
    auto-optimise-store = true;
    
    # Performance de Download (Fedora Style)
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org" 
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Conexões paralelas para baixar pacotes
    max-substitution-jobs = 20;
    download-attempts = 5;
    connect-timeout = 5;
    
    # Segurança e Sandboxing (Inspirado no rigor do OpenBSD)
    sandbox = true;
    sandbox-fallback = false;
    # A linha 'always-succeed-tests' foi removida para evitar o erro de validação
    log-lines = 25;

    # Performance de Build (Ajustado para o i5 7ª gen)
    cores = 4;
    max-jobs = "auto";
    
    # Mantém apenas o necessário para builds rápidos e análise de erros
    keep-outputs = true;
    keep-derivations = true;
  };

  # --- 2. Nix Daemon Performance ---
  # Prioridade de processo: garante fluidez total no Desktop enquanto o Nix trabalha
  systemd.services.nix-daemon.serviceConfig = {
    OOMScoreAdjust = 250;
    CPUSchedulingPolicy = lib.mkForce "idle"; 
    Nice = lib.mkForce 19; # mkForce garante que nenhum outro módulo mude isso
  };

  # --- 3. Garbage Collection & Otimização (Foco no Stripe de 2TB) ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  nix.optimise.automatic = true;
  
  # --- 4. Unfree & Nixpkgs ---
  nixpkgs.config.allowUnfree = true;
}