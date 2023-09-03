{ config, pkgs, ... }:

{
  # Enable the OpenSSH server.
  services.sshd.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };
}