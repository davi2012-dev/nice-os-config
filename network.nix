{ config, pkgs, ... }: {
  networking.hostName = "Darkflake";
  networking.hostId = "ac9441c8";

  # --- 1. Network Stack "Encalista" (Fedora/OpenBSD) ---
  networking.networkmanager = {
    enable = true;
    dns = "none";
    # Fedora usa IWD por padrão em instalações modernas: mais rápido e estável que wpa_supplicant
    wifi.backend = "iwd"; 
  };
  
  networking.useDHCP = false;
  networking.enableIPv6 = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = "strict";
    
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];

    # Regras inspiradas no 'pf' do OpenBSD: Eficiência bruta
    extraInputRules = ''
      # Descarte imediato de pacotes inválidos sem processar nada (OpenBSD-like)
      ct state invalid drop
      
      # Mitigação de SYN Flood agressiva
      tcp flags & (fin|syn|rst|ack) == syn ct count over 500 drop
      
      # Priorizar tráfego de controle (DNS/ACKs) usando DSCP
      tcp dport { 53, 853 } ip dscp set cs6
    '';
  };

  # --- 2. Samba: SMB 3.1.1 + RDMA & Zero-Copy ---
  services.samba = {
    enable = true;
    openFirewall = false;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server min protocol" = "SMB3_11";
        
        # Tecnologias de baixa latência do Fedora Server
        "server multi channel support" = "yes";
        "use sendfile" = "yes";
        "aio read size" = "1";
        "aio write size" = "1";
        
        # Socket Tuning estilo OpenBSD
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_KEEPALIVE TCP_FASTOPEN";
        
        # Otimização de alocação de arquivos
        "allocation roundup size" = "0";
        "min receivefile size" = "16384";
        "getwd cache" = "yes";
      };
      "Public" = {
        "path" = "/srv/samba/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
      };
    };
  };

  # --- 3. DNS Unbound: Hardened & Fast ---
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" "::1" ];
        port = 53;
        
        # "Serve-Expired" e "Zero-TTL": O auge da velocidade
        serve-expired = "yes";
        serve-expired-ttl = 86400;
        prefetch = "yes";
        prefetch-key = "yes";
        
        # Segurança do OpenBSD (Rigoroso)
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        use-caps-for-id = "yes"; # Técnica para evitar spoofing
        edns-buffer-size = "1232"; # Otimizado para não fragmentar
        
        # Tunning de Memória (Fedora Workstation/Server)
        msg-cache-slabs = 8;
        rrset-cache-slabs = 8;
        num-threads = 4;
      };
      forward-zone = [{
        name = ".";
        forward-addr = [ "1.1.1.1@853#cloudflare-dns.com" "9.9.9.9@853#dns.quad9.net" ];
        forward-tls-upstream = "yes";
      }];
    };
  };

  # --- 4. Sysctl: O "Creme de la Creme" (Network Tuning) ---
  boot.kernel.sysctl = {
    # BBR + FQ: A combinação do Fedora para latência mínima sob carga
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # TCP Fast Open (Handshake em 1 RTT)
    "net.ipv4.tcp_fastopen" = 3;
    
    # Buffers "OpenBSD Style" (Largas o suficiente, mas sem desperdício)
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    
    # Evitar o "Slow Start" após ociosidade
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # --- 5. Logs e Manutenção (Fedora Performance) ---
  # Logs em RAM para não engasgar o I/O de disco
  services.journald.extraConfig = "Storage=volatile\nRuntimeMaxUse=64M";

  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.resolvconf.enable = true;
  boot.consoleLogLevel = 3;
}