{ config, pkgs, ... }: {

  # Instala o EtherApe e outras ferramentas de análise de rede
  environment.systemPackages = with pkgs; [
    etherape    # Monitoramento gráfico de tráfego
    wireshark   # O clássico para análise de pacotes
    termshark   # Wireshark para o terminal (estilo BSD)
    nmap        # Scanner de rede
    lynis  
];
  
  
  security.wrappers.etherape = {
  source = "${pkgs.etherape}/bin/etherape";
  capabilities = "cap_net_raw,cap_net_admin+eip";
  owner = "root";
  group = "wireshark"; # Ou o grupo que seu usuário pertence
  permissions = "u+rx,g+rx,o+r";
}; 

  # Permite que o EtherApe e Wireshark capturem pacotes sem precisar de ROOT (Segurança!)
  programs.wireshark.enable = true;
  
  # Adiciona seu usuário ao grupo de captura de rede
  users.users.davi.extraGroups = [ "wireshark" ];
}
