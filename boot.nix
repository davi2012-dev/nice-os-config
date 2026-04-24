{ config, pkgs, ... }: {
  boot.loader = {
    # Habilita o systemd-boot (o sucessor do gummiboot)
    systemd-boot.enable = true;
    
    # Impede que o sistema mude as variáveis EFI se você não quiser
    efi.canTouchEfiVariables = true;

  };

  # Isso é vital para o ZFS pedir a senha no boot com systemd-boot
  boot.zfs.requestEncryptionCredentials = true;

  # Limpeza estilo OpenBSD
  boot.tmp.cleanOnBoot = true;
}
