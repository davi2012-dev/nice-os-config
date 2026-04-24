{ config, pkgs, lib, ... }: {

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    updater.interval = "12h"; 

    daemon.settings = {
      # --- SCAN EM TEMPO REAL ---
      OnAccessMaxFileSize = "150M";
      OnAccessIncludePath = [ "/home/davi" ]; 
      OnAccessMountPath = [ "/" ]; # Focado no seu ZFS
      OnAccessPrevention = true;   # BLOQUEIA o arquivo se for suspeito
      OnAccessExtraScanning = true;

      # --- MODO AGRESSIVO (PUTO) ---
      DetectPUA = true;            # Detecta Adwares/Miners
      HeuristicAlerts = true;      # Heurística atômica
      HeuristicScanPrecedence = true;
      StructuredDataDetection = true; # Procura vazamento de dados
      Bytecode = true;
      BytecodeSecurity = "TrustSigned";
      
      # --- LIMITES DE SEGURANÇA ---
      MaxScanSize = "200M";
      MaxFileSize = "150M";
      AlertBrokenExecutables = true;
      AlertEncrypted = true;       # Desconfia de tudo que está trancado
    };
  };

  # --- CONFIGURAÇÃO DE PRIORIDADE ATÔMICA ---
  systemd.services.clamav-daemon = {
    serviceConfig = {
      # Identidade de Super-Usuário
      Capabilities = "CAP_SYS_ADMIN CAP_IPC_LOCK";
      User = lib.mkForce "root";
      Group = lib.mkForce "root";

      # Prioridade Real-Time para o i5 não engasgar
      CPUSchedulingPolicy = "fifo";
      CPUSchedulingPriority = 99;
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 0;

      # Imortalidade contra falta de RAM (OOM Killer ignora)
      OOMScoreAdjust = -1000;

      # Reinicialização Instantânea em caso de crash
      Restart = "always";
      RestartSec = "1s";

      # --- LIBERANDO A JAULA TOTAL ---
      ProtectHome = lib.mkForce false;
      ProtectSystem = lib.mkForce false;
      PrivateTmp = lib.mkForce false;
      ReadOnlyPaths = lib.mkForce [ ];
    };
  };

  environment.systemPackages = with pkgs; [ clamav ];
}
