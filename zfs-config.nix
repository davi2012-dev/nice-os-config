{ config, pkgs, ... }: {
  networking.hostId = "ac9441c8"; 

  boot.zfs.forceImportRoot = true;
  services.zfs.autoScrub.enable = true;
  
 
  services.zfs.trim.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-path";

  boot.zfs.requestEncryptionCredentials = true;

  boot.kernelParams = [ "zfs.zfs_arc_max=8589934592" ]; 
}