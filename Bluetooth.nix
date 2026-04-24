{ pkgs, ... }:

{
  # --- 1. Hardware Bluetooth com Tecnologia Experimental ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    
    settings = {
      General = {
        # 'Source,Sink,Media,Socket' permite que o PC seja tanto fone quanto caixa de som
        Enable = "Source,Sink,Media,Socket";
        
        # Tecnologia Encalista: Melhora o pareamento de fones modernos (LE Audio)
        # e mostra a bateria de mouses/teclados no sistema.
        Experimental = true;
        
        # FastConnect: Reduz o tempo de reconexão de dispositivos já pareados
        FastConnectable = true;
        
        # Melhora a coexistência entre WiFi e Bluetooth (evita interferência)
        Class = "0x000100";
      };
      
      # Otimização para Áudio de Alta Fidelidade (Estilo Fedora/PipeWire)
      Policy = {
        AutoEnable = "true";
      };
    };
  };

  # --- 2. Gerenciamento e Serviços ---
  # Blueman para interface gráfica, mas com suporte a transferência de arquivos (OBEX)
  services.blueman.enable = true;

  # --- 3. Áudio Bluetooth de Baixa Latência (O segredo do Fedora) ---
  # Isso garante que codecs como LDAC, AptX e AAC funcionem perfeitamente.
  services.pipewire = {
    enable = true;
    wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true; # Áudio SBC de alta qualidade
          "bluez5.enable-msbc" = true;   # Melhora o microfone em chamadas BT
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "headset_head_unit" "headset_audio_gateway" ];
        };
      };
    };
  };

  # --- 4. Kernel Tuning para Bluetooth (Estilo OpenBSD/Hardened) ---
  # Ativa o suporte a HIDP (controles e teclados) com prioridade
  boot.kernelModules = [ "hidp" ];
}