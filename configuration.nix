{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./zfs-config.nix
      ./boot.nix
      ./network.nix
      ./idioma.nix
      ./user.nix
      ./desktop.nix
      ./app.nix
      ./fun.nix
      ./podman.nix
      ./Blacklist.nix
      ./kernel.nix
      ./nix.nix
      ./hell.nix
      ./users.motd.nix    
      ./swap.nix
      ./ananicy-cpp.nix
      ./Bluetooth.nix      
      ./ClamAV.nix
     # ./AppArmor.nix
      ./supergfxd.nix
];

  system.stateVersion = "25.11";
}
