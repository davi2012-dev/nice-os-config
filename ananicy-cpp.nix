{ config, pkgs, ... }:

{
  # 1. Habilita o daemon Ananicy-CPP
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    
    # 2. Aqui está o segredo: usar as regras do CachyOS para performance máxima
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # 3. Garante que o pacote esteja disponível no sistema para monitoramento
  environment.systemPackages = [ 
    pkgs.ananicy-cpp 
  ];
}
