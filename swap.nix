{ config, lib, pkgs, ... }:

{
  # 1. Ativa o ZRAM (Swap comprimido na RAM)
  # Isso é extremamente rápido e evita usar o disco 90% do tempo
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # O seu favorito, para compressão máxima
    memoryPercent = 50; # Usa até 50% da sua RAM como cache comprimido
  };

  # 2. Ativa o ZVOL (Swap no disco como backup)
  swapDevices = [
    { 
      device = "/dev/zvol/zroot/swap";
      # Prioridade menor (5) para que o sistema use o ZRAM (prioridade maior) primeiro
      priority = 5; 
    }
  ];

  # 3. Ajuste do Kernel para esse combo
  boot.kernel.sysctl = {
    "vm.swappiness" = 100; # Com ZRAM, pode aumentar! O kernel vai preferir comprimir na RAM do que apagar cache.
    "vm.page-cluster" = 0; # Melhora a latência do ZRAM
  };
}
