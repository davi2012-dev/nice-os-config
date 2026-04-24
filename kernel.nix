{ config, pkgs, ... }: {
  # --- 1. Kernel Zen (Otimizado para Desktop/Gaming/Low Latency) ---
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --- 2. Parâmetros de Boot: Performance Bruta e Blindagem ---
  boot.kernelParams = [
    # Performance de Processamento
    "threadirqs"           # Força threads para interrupções (ganho de latência)
    "preempt=full"         # Preempção total para resposta instantânea
    "skew_tick=1"          # Ajuda em CPUs com jitter de clock
    "nowatchdog"           # Desativa o NMI watchdog (economiza ciclos de CPU)
    "nosoftlockup"         # Ganho em cargas extremas
    
    # Segurança de Memória e CPU (Hardening estilo OpenBSD)
    "slab_nomerge"         # Impede fusão de caches slab (trava ataques de heap)
    "page_alloc.shuffle=1" # Randomização de RAM (ASLR no hardware)
    "vsyscall=none"        # Mata syscalls obsoletas que são vetores de ataque
    "debugfs=off"          # Fecha a porta para ferramentas de depuração maliciosas
    "randomize_kstack_offset=on" # Proteção extra contra estouro de pilha
    "init_on_alloc=1"
    "init_on_free=1"
    "page_poison=on"
    "slub_debug=FZP"
    "spectre_v2_user=on"
    "scx_ops_bypass=1"
    "psi=1"
    "transparent_hugepage=always"
    "lru_gen=1"
    "mce=on"
    "ras=on"
    "panic=10"
    "nmi_watchdog=0"
    "memory_hotplug=on"
               
    # Proteções Intel 7th Gen (Essenciais para segurança vs performance)
    "spectre_v2=on"
    "pti=on"               # Page Table Isolation (Meltdown mitigation)
    "l1tf=full,force"      # Mitigação L1 Terminal Fault
    "intel_iommu=on"
    "iommu=pt"  
];

  # --- 3. Sysctl: Otimizações de "Elite" para Rede e Memória ---
  boot.kernel.sysctl = {
    # Performance de I/O e RAM (Samba e Stripe de 2TB)
    "vm.vfs_cache_pressure" = 50;    # Mantém cache de arquivos em RAM por mais tempo
    "vm.dirty_ratio" = 10;           # Flush de dados mais frequente para evitar stalls
    "vm.dirty_background_ratio" = 5;
    "kernel.io_uring_enabled" = 1;
    "kernel.io_uring_disabled" = 0;
    "vm.lru_gen_stats" = 1;
    "vm.nr_hugepages" = 0;
    "vm.transparent_hugepage" = "always";
    "vm.transparent_hugepage_defrag" = "defer+madvise";
    "net.core.somaxconn" = 8192;
    "net.core.netdev_max_backlog" = 16384;
    "vm.max_map_count" = 2147483647;
    "vm.memory_failure_recovery" = 1;
    "vm.memory_failure_early_kill" = 0;
    "vm.compaction_proactiveness" = 0;
    
        
    # Scheduler: Interatividade Máxima (Estilo Fedora Workstation)
    "kernel.sched_autogroup_enabled" = 1;
    "kernel.sched_cfs_bandwidth_slice_us" = 500; # Fatias de tempo menores = maior fluidez
    "kernel.sched_latency_ns" = 1000000;
    "kernel.sched_min_granularity_ns" = 100000;
    "kernel.sched_wakeup_granularity_ns" = 100000;
    
    # Hardening de Rede e Kernel
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.unprivileged_userns_clone" = 0; # Desativa clones de user namespace pra não-root
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
  } ;

  # --- 4. Blacklist de Módulos (Redução de Superfície de Ataque) ---
  boot.blacklistedKernelModules = [ 
    "ax25" "netrom" "rose" # Protocolos de rádio amador (inúteis e inseguros)
    "dccp" "sctp" "rds"    # Protocolos de rede exóticos/vulneráveis
    "uvcvideo"             # Webcam (Desative se não usar, segurança física)
    "firewire-core"        # Tecnologia morta e perigosa (DMA attack)
  ];

  # --- 5. Firmware e Segurança de Imagem ---
  security.protectKernelImage = true; # Impede modificação do kernel em runtime
  security.unprivilegedUsernsClone = false;
  
  hardware.cpu.intel.updateMicrocode = true; # Correções de segurança da Intel
  hardware.enableAllFirmware = true;         # Garante drivers de performance máxima
}
